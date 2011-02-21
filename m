From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [Lxc-users] Huge ammount of invalid checksum packets on macvlan
Date: Mon, 21 Feb 2011 17:07:31 +0100
Message-ID: <4D628DC3.9000400@free.fr>
References: <20110221150710.GA5651@nord.niifaq.ru> <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lxc-users@lists.sourceforge.net, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andrian Nord <nightnord@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:53160 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967Ab1BUQHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 11:07:43 -0500
In-Reply-To: <20110221153421.GA6602@nord.niifaq.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2011 04:34 PM, Andrian Nord wrote:
> Greetings, Daniel.
>
> On Mon, Feb 21, 2011 at 04:20:59PM +0100, Daniel Lezcano wrote:
>
> 2.6.37 kernel with gentoo linux patches (doesn't affect any low-syste=
m
> stuff, AFAIK).
> lxc-0.7.2 is used.
>
> Reproducable on two different machines.
> I'm using tcpdump -vvv for bad checksum detection. This also affects
> traffic from container to hardware node (as it's using macvlan to
> communicate with containers by itself).
>
> Also, I've got same problem on UDP packets coming from lan on other
> server and it was worked around by disabeling tx and rx checksum offl=
oad
> via ethtool. But dummy devices doesn't allow this.

I am not sure it is a bug. If we go outside of the container context an=
d=20
we do the following:

ssh 127.0.0.1
tcpdump -vvv -i lo

We will get the same errors AFAICS.

There is also in the man page the following option:

-K Don't attempt to verify IP, TCP, or UDP checksums. This is useful fo=
r=20
inter=E2=80=90
faces that perform some or all of those checksum calculation in=20
hardware; other=E2=80=90
wise, all outgoing TCP checksums will be flagged as bad.

IMO, the checksum is not needed for the virtual macvlan devices, hence=20
the checksum is not computed and the checksum tcp packet is not filled.=
=20
As the skb's are flagged as 'checksum not necessary' the packets are no=
t=20
dropped by the kernel and are delivered to the network stack. tcpdump=20
intercept the raw packet and analyse the header. It will see a bad valu=
e=20
as this one is a default value.

I Cc'ed the netdev mailing list and Patrick in case my analysis is wron=
g=20
or incomplete.

Thanks
-- Daniel

