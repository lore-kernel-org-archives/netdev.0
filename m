From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Thu, 2 Jan 2014 10:56:17 -0800 (PST)
Message-ID: <1388688977.95873.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm38.bullet.mail.ne1.yahoo.com ([98.138.229.31]:30892 "HELO
	nm38.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751574AbaABS7H convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 13:59:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1/2/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

>> This change allows to follow a recommandation of RFC4942.
>>=20
>> - Add "enable_anycast_src" sysctl to control the use of Subnet-Route=
r anycast
>>=A0=A0=A0addresses as source addresses. This sysctl is false by defau=
lt to preserve
>>=A0=A0=A0existing behavior.
>> - Use it in ip6_datagram_send_ctl() and icmpv6_echo_reply().
=20
 > It is very cool that you are working on this. I had this on my TODO =
list for a
 long time.

Thanks,I think also it is useful.

>> Reference:
>> RFC4942 - IPv6 Transition/Coexistence Security Considerations
>>=A0 =A0 (http://tools.ietf.org/html/rfc4942#section-2.1.6)
>>=20
>> 2.1.6. Anycast Traffic Identification and Security
>>=20
>>=A0 =A0 [...]
=20
> Actually, the restriction was lifted by RFC 4291 ("IP Version 6
> Addressing Architecture").
=20
Exact.
=20
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/n=
etworking/ip-sysctl.txt
> index d71afa8..2a062a7 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1094,6 +1094,12 @@ bindv6only - BOOLEAN
>=A0=20
>=A0 =A0=A0=A0 Default: FALSE (as specified in RFC3493)
>=A0=20
> +enable_anycast_src - BOOLEAN
> +=A0=A0=A0 Controls the use of Subnet-Router anycast addresses as sou=
rce addresses
> +=A0=A0=A0 TRUE:=A0 enabled
> +=A0=A0=A0 FALSE: disabled
> +=A0=A0=A0 Default: FALSE
> +
=20
> I wouldn't actually add this knob, we can just enable that by default=
=2E

I think we need to keep by default the existing behaviour (ICMPv6 echo =
reply with unicast)
in case some setups use it, and use "enable_anycast_src" to change the =
behaviour=20
according to RFC4942.

> Also it should be no problem to bind() to those addresses.
=20
> I am still unsure what to do with a bind to any or if the address mus=
t be
> bound specifically (maybe that is worth a knob).

> In the long term I would like to see that we can add additional anyca=
st
> addresses via iproute:
=20
> ip -6 a a 1234::1/64 dev eth0 anycast
=20
> or something like that. That should be rather easy, as in just increm=
enting
> the anycast counter for an interface in inet6_rtm_newaddr
> and adding a flag to ifa_flags which gets passed down by iproute2.
=20
> I'll do some research on if this should also get integrated with sour=
ce address selection.

It can be the objects of future evolutions.
I have to think about these.
=20
> Hannes
=20
Thanks,
=46rancois-Xavier
