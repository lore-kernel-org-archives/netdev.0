From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH v2] tipc: fix build issue when building without IPv6
Date: Mon, 23 Mar 2015 11:00:17 +0800
Message-ID: <550F81C1.4020701@windriver.com>
References: <20150319.150433.850095478975909930.davem@davemloft.net> <1426794478-5469-1-git-send-email-marcelo.leitner@gmail.com> <20150319.160658.1294624225284354605.davem@davemloft.net> <550B8156.3020400@windriver.com> <9df97f7f63e5c844ede07f1e6ec45c4e@propriete.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <richard.alpe@ericsson.com>,
	<jon.maloy@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>, <erik.hugne@ericsson.com>
To: Marcelo <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55328 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbbCWDAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 23:00:46 -0400
In-Reply-To: <9df97f7f63e5c844ede07f1e6ec45c4e@propriete.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2015 08:35 PM, Marcelo wrote:
> I think David and Willem suggestion were more about the dependencies
> than fixing the build issue itself. I mean, if some part of TIPC real=
ly
> needs IPv6 in order to work or something like that.
>=20
> So if all we want to do if fix the build issue, I have another sugges=
tion.
> When we have IPV6=3Dm and TIPC=3Dy, just have to use the stub too.
>=20
> (cut & pasted)
> --- a/net/tipc/udp_media.c
> +++ b/net/tipc/udp_media.c
> @@ -193,7 +193,7 @@ static int tipc_udp_send_msg(struct net *net, str=
uct
> sk_buff *skb,
>                         .saddr =3D src->ipv6,
>                         .flowi6_proto =3D IPPROTO_UDP
>                 };
> -               err =3D ip6_dst_lookup(ub->ubsock->sk, &ndst, &fl6);
> +               err =3D ipv6_stub->ipv6_dst_lookup(ub->ubsock->sk, &n=
dst,
> &fl6);
>                 if (err)
>                         goto tx_error;
>                 ttl =3D ip6_dst_hoplimit(ndst);
>=20
> then it builds fine here. That is, assuming that you can't reach this=
 code
> while
> ipv6 module is unloaded.. (I didn't check that) what do you think?

It seems that your above change is useless to kill the error. For insta=
nce, when
I apply it into my project, below build error appears:

net/tipc/udp_media.c: In function =E2=80=98tipc_udp_send_msg=E2=80=99:
net/tipc/udp_media.c:196:18: error: =E2=80=98const struct ipv6_stub=E2=80=
=99 has no member named
=E2=80=98ip6_dst_lookup=E2=80=99
make[2]: *** [net/tipc/udp_media.o] Error 1
make[1]: *** [net/tipc] Error 2
make: *** [net] Error 2

In my opinion, we have to follow David's suggestion dividing the udp_me=
dia.c as
an separate module.

Regards,
Ying
