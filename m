From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as source addresses in ICMPv6 error messages
Date: Thu, 6 Feb 2014 06:30:41 -0800 (PST)
Message-ID: <1391697041.6325.YahooMailNeo@web125505.mail.ne1.yahoo.com>
References: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com> <52F357C3.9060406@6wind.com> <1391690329.62545.YahooMailNeo@web125506.mail.ne1.yahoo.com> <52F395BB.2030209@6wind.com>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	Bill Fink <billfink@mindspring.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm34.bullet.mail.ne1.yahoo.com ([98.138.229.27]:25890 "EHLO
	nm34.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754605AbaBFOdn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 09:33:43 -0500
In-Reply-To: <52F395BB.2030209@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> To: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>; "netdev@vger.ker=
nel.org" <netdev@vger.kernel.org>
> Cc: David Stevens <dlstevens@us.ibm.com>; Bill Fink <billfink@mindspr=
ing.com>; Hannes Frederic Sowa <hannes@stressinduktion.org>; David S. M=
iller <davem@davemloft.net>; Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>; J=
ames Morris <jmorris@namei.org>; Hideaki Yoshifuji <yoshfuji@linux-ipv6=
=2Eorg>; Patrick McHardy <kaber@trash.net>
> Sent: Thursday, February 6, 2014 3:01 PM
> Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as so=
urce addresses in ICMPv6 error messages
>=20
> Le 06/02/2014 13:38, Fran=E7ois-Xavier Le Bail a =E9crit :
>>>  From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>=20
>>=20
>>>  Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as=
=20
> source addresses in ICMPv6 error messages
>>>=20
>>>  Le 19/01/2014 17:00, Francois-Xavier Le Bail a =E9crit :
>>>=20
>>>> =A0  - Uses ipv6_anycast_destination() in icmp6_send().
>>>>=20
>>>> =A0  Suggested-by: Bill Fink <billfink@mindspring.com>
>>>> =A0  Signed-off-by: Francois-Xavier Le Bail=20
> <fx.lebail@yahoo.com>
>>>  This patch causes an Oops on my target.
>>=20
>>  What is your target ?
> x86 32bits
>=20
>>=20
>>>  Here is the step to reproduce it:
>>>  modprobe sit
>>>  ip link add sit1 type sit remote 10.16.0.121 local 10.16.0.249
>>>  ip l s sit1 up
>>>  ip -6 a a dev sit1 2001:1234::123 remote 2001:1234::121
>>>  ping6 2001:1234::121
>>=20
>>  I cannot reproduce this in my target (updated net-next x86_64) and
>>  iproute2 from git.
> I use linus tree (3.14-rc1+).
>=20
>>  Can you send me your config file ?
> See attachment.
>=20
>=20
>>=20
>>>  The problem is that ipv6_anycast_destination() uses unconditionall=
y
>>>  skb_dst(skb), which is NULL in this case.
>>>=20
>>>  Not sure what is the best way to fix this, any suggestions?
>>=20
>>  I will try to reproduce first and see.
> Note that the peer was not set up, hence the ping didn't work.
> ipip6_err() calls ipip6_err_gen_icmpv6_unreach() which will drop the =
dst
> before calling icmpv6_send().
>=20
>=20
> Here is the backtrace:
> [=A0 387.786155] BUG: unable to handle kernel NULL pointer dereferenc=
e at 00000096
> [=A0 387.787291] IP: [<c12f1568>] icmp6_send+0x79/0x596

[...]

> [=A0 387.790055]=A0 [<f85ce03b>] ? tunnel64_err+0x16/0x25 [tunnel4]

Thanks for these informations.

Can you test an alternative replacing:

test on: ipv6_anycast_destination(skb)
by
test on: ipv6_chk_acast_addr_src(net, skb->dev, &hdr->daddr)

Greetings
