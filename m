From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 1 Feb 2012 00:32:04 +0100
Message-ID: <CAGsizzLTHw5Ja3kT-zEN8uK5GrzpmN1bxOhA0OscGL5R6tH3WA@mail.gmail.com>
References: <12547555.801328015432974.JavaMail.root@5-MeO-DMT.ynet.sk>
 <4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk> <20120131.115005.1292336126288944173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120131.115005.1292336126288944173.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/31 David Miller <davem@davemloft.net>:
> From: Stefan Gula <steweg@ynet.sk>
> Date: Tue, 31 Jan 2012 14:21:51 +0100 (CET)
>
>> =A0 - neither NVGRE nor VXLAN are part of the openvswitch for now
>
> Too bad, it means we'll have this new user API of your's so when
> openvswitch does add the necessary code we CANNOT REMOVE your stuff.
>
> I'm not applying this until you at least attempt an openvswitch
> version, and that's basically the end of this discussion.
I actually tried to deploy it on one of my linux based APs. And that's
when I realize that openvswitch have several limitations why I cannot
use it in my scenario on it's own. I tried to put only standard one
point-to-point GRE tunnel from openvswitch without any modifications
of my own and find out that it will never work ok as it is missing the
security parts (ebtables/arptables/iptables), so in my scenario I end
up with original bridge for security and openvswitch bridge with
opevswitch gre tunnel, all linked together by veth link. Result of
performance was that (veth code + openswitch bridge + openvswitch gre
code) was worse than using only my gretap code. On the other hand if I
omit the fact about the missing the security features (omitting also
use of the original bridge code), then the result was in favor of
openvswitch (that's the same result as Joseph provided).

About the new API. Openvswitch is using it's own GRE code, with it's
own API. So if the finally NVGRE or VXLAN will be added to
openvswitch,it doesn't breaks anything to leave also my API as is. For
those who will be using my API in that time, they could consider
migrations of their scripts from standard bridge based code with
gretap interfaces towards openvswitch with NVGRE code or VXLAN code
instead. Until that time they can consider using bridge code with
gretap interfaces or openvswitch code with the same gretap interfaces
=3D> both switches can benefit from it. So no harm done on this side -
maybe I am not seeing something that you do, am I?

About the porting of my code into openvswitch directly. I believe that
developing/porting something, that will be most probably replaced
eventually with something based on RFC standards like NVGRE, which is
still in progress of developing, and cannot be really used in managed
networks, like my own, at all due other missing features, is a huge
waste of anybody's time.
