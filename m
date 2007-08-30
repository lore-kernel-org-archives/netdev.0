From: James Chapman <jchapman@katalix.com>
Subject: Re: malformed captured packets
Date: Thu, 30 Aug 2007 10:51:31 +0100
Message-ID: <46D69323.3070503@katalix.com>
References: <200708281811.34074.toralf.foerster@gmx.de> <46D521BC.1050300@katalix.com> <200708291822.35128.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:41321 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153AbXH3Jvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 05:51:33 -0400
In-Reply-To: <200708291822.35128.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Toralf F=F6rster wrote:
> Am Mittwoch, 29. August 2007 schrieb James Chapman:
>=20
>> Can you provide more information about the problem, please? Are you=20
>> using a simple DSL modem with PPPoE, such that the ppp0 interface is=
=20
>> that of the pppd started by a local PPPoE server? Is this a problem =
only=20
>> with packet capture or are you seeing actual data corruption? Did th=
is=20
>> work with previous kernels? What is the network topology related to =
the=20
>> DSL interface?
>>
>=20
> I use a ThinkPad T41 with this Ethernet controller:
>=20
> n22 ~ # lspci | grep Eth
> 02:01.0 Ethernet controller: Intel Corporation 82540EP Gigabit Ethern=
et Controller (Mobile) (rev 03)
> 02:02.0 Ethernet controller: Atheros Communications, Inc. AR5212 802.=
11abg NIC (rev 01)
>=20
> My DSL provider is Alice DSL (formerly Hansenet) in Hamburg. The T41 =
is connected
> with an Ethernet cable to a Siemens DSL modem. The modem (just a mode=
m, not a
> router) itself is connected to the DSL splitter which itself is plugg=
ed into socket.
>=20
> The current ppp version I'm using is net-dialup/ppp-2.4.4-r9
>=20
> Here are my kernel config settings:
>=20
> n22 ~ # zgrep PPP /proc/config.gz
> CONFIG_PPP=3Dm
> # CONFIG_PPP_MULTILINK is not set
> CONFIG_PPP_FILTER=3Dy
> # CONFIG_PPP_ASYNC is not set
> # CONFIG_PPP_SYNC_TTY is not set
> CONFIG_PPP_DEFLATE=3Dm
> # CONFIG_PPP_BSDCOMP is not set
> # CONFIG_PPP_MPPE is not set
> CONFIG_PPPOE=3Dm
>=20
> I observed this problem since a long time with different kernel versi=
ons (Gentoo,
> plain vanilla kernel, git sources) while playing with ethereal - curr=
ently known
> as wireshark.
>=20
> I'm wondering b/c for kscd eg. it is always the IP packet containing =
the content
> information of a CD (or even a <CD is unknown> message) with is strug=
gled.
> This packets prevents me from using the "Follow TCP Strem" feature of=
 wireshark
> for an easy look into the plain text of all TCP packets of this HTTP =
stream
> (which was in fact the trigger for me to have a deeper look into the =
sniffed
> stream from ppp0 and eth0).
>=20
> For other apps I observed similar things which cannot fully be explai=
ned by
> terms like "TCP checksum offloading".=20
>=20
> I didn't observed any malfunction at application level so it might be=
 an issue
> with the capturing itself.
>=20
> Why is the ppp stream always ok in opposite to the eth0 stream ?

Toralf, thanks for providing more info about your setup.

Are you using kernel-mode PPPoE? I know some PPPoE servers do the PPPoE=
=20
datapath in userspace...

The captured PPPoE stream seems to show incorrect data lengths in the=20
PPPoE header for some captured PPPoE packets. The kernel's PPPoE=20
datapath uses this length to extract the PPP frame and send it through=20
to the ppp interface. Since your ppp stream is fine, the actual PPPoE=20
header contents must be correct when it is parsed by the kernel PPPoE=20
code. It seems more likely that this is a wireshark bug to me.

Is it possible to get captures from ppp0 and eth0 simultaneously such=20
that they show the same ppp instance? This might give more clues.

--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

