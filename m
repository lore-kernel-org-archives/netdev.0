From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPV6 address lifetime update
Date: Wed, 15 Dec 2010 16:33:07 -0500
Message-ID: <4D093413.5030001@hp.com>
References: <4D091812.8060109@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Abhijeet Dharmapurikar <adharmap@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:6439 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab0LOVdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 16:33:13 -0500
In-Reply-To: <4D091812.8060109@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2010 02:33 PM, Abhijeet Dharmapurikar wrote:
> Our product uses Linux kernel 2.6.35.  For IPV6 support, the device i=
s using stateless address configuration. We see the global scope addres=
s is assigned correctly when the network interface transitions to UP st=
ate.  However, we are seeing issue where subsequent router advertisemen=
t (RA) messages for assigned prefix results in *new* IPV6 address on sa=
me interface and duplicate-address-detection for same.  Our goal is to =
have the subsequent router RA message simply update the address lifetim=
e for existing IPV6 address(es) using the specific prefix per RFC2462 s=
ection 5.5.3(e).  Looking at /net/ipv6/addrconf.c function addrconf_pre=
fix_rcv(), it does not seem like updating existing addresses only (with=
out new address creation) is supported.  Is this correct?  Or what conf=
iguration options are required to achieve the desired behavior?
> Below is an excerpt from =91ip addr=92 output, showing interface stat=
e after a few RA messages have been received.  Note we have configured =
the router to send RA frequently for testing purposes.  Ideally only on=
e global address will be present, with lifetime updated on each RA arri=
val for same prefix.
> Thank you in advance for guidance on this issue.
>=20
> 3: net0: <UP,LOWER_UP> mtu 1280 qdisc pfifo_fast qlen 1000
>     link/[530]

What type of interface is this?  Doesn't look like Ethernet.

>     inet6 2002:c023:9c17:c23:f2f9:6c83:be61:a743/64 scope global dyna=
mic
>        valid_lft 7170sec preferred_lft 3570sec
>     inet6 2002:c023:9c17:c23:1282:1b78:75dd:b9ed/64 scope global dyna=
mic
>        valid_lft 7150sec preferred_lft 3550sec
>     inet6 2002:c023:9c17:c23:5326:714d:e25b:797e/64 scope global dyna=
mic
>        valid_lft 7134sec preferred_lft 3534sec
>     inet6 2002:c023:9c17:c23:488c:95c8:34a2:587f/64 scope global dyna=
mic
>        valid_lft 7117sec preferred_lft 3517sec
>     inet6 fe80::97e0:7661:c51d:bdb/64 scope link
>        valid_lft forever preferred_lft forever

These don't look like privacy addresses since they'd have either "tempo=
rary"
or "secondary", someone is generating a MAC though...

-Brian
