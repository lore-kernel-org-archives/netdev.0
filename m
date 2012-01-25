From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 23:30:46 +0100
Message-ID: <CAGsizz+XZ79SstTTDfAwuHHqA40dxvr5cZLPph4U1euxexpVUQ@mail.gmail.com>
References: <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
 <20120125085712.524b65a8@nehalam.linuxnetplumber.net> <CAGsizzKAvAV771vSo0TGx_sU5qXgjOOqVRooK9vOf=XEi1NtXA@mail.gmail.com>
 <20120125.164939.1360578908839469758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:46144 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab2AYWbG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 17:31:06 -0500
In-Reply-To: <20120125.164939.1360578908839469758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/25 David Miller <davem@davemloft.net>:
> From: =C5=A0tefan Gula <steweg@ynet.sk>
> Date: Wed, 25 Jan 2012 22:01:08 +0100
>
>> 2012/1/25 Stephen Hemminger <shemminger@vyatta.com>:
>>> On Wed, 18 Jan 2012 00:33:14 +0100 (CET)
>>> Stefan Gula <steweg@ynet.sk> wrote:
>>>
>>>> From: Stefan Gula <steweg@gmail.com>
>>>>
>>>> This patch is an extension for current Ethernet over GRE
>>>> implementation, which allows user to create virtual bridge (multip=
oint
>>>> VPN) and forward traffic based on Ethernet MAC address information=
 in
>>>> it. It simulates the Bridge behavior learning mechanism, but inste=
ad
>>>> of learning port ID from which given MAC address comes, it learns =
IP
>>>> address of peer which encapsulated given packet. Multicast, Broadc=
ast
>>>> and unknown-multicast traffic is send over network as multicast
>>>> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can=
 be
>>>> represented as one single virtual switch on logical level and be a=
lso
>>>> represented as one multicast IPv4 address on network level.
>>>>
>>>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>>>
>>> Will this break normal usages of GRE?
>>> Compile time options are not acceptable for a standard distribution=
 if
>>> it will break it for the other case. It is fine to add the addition=
al data
>>> structure elements, but the code in the receive path might get brok=
en?
>>>
>>>
>> No, if you don't decide to compile with given kernel option.. nothin=
g
>> happens and original GRE code is leaved intact.
>
> Every distribution is going to want to turn the option on to provide
> the feature to their users, so this line of reasoning is not
> acceptable.
On the other hand, if you enable the compile this option, it modifies
the behavior only when you are using this command to create the
interface:
ip link add vpn0 type gretap local 1.2.3.4 remote 239.192.0.1 key 12345=
 ttl 10
please notice two major keywords:
 - gretap
 - 239.192.0.1
My patch modifies the code behavior only if you used "gretap" and
remote IP must be valid multicast IP address. In every other
combinations it is still using plain original GRE codes. So enabling
it doesn't breaks anything else.
