From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix a bug in emitting the 16-bit immediate operand of
 AND
Date: Thu, 29 Mar 2012 13:45:25 +0200
Message-ID: <1333021525.3402.22.camel@edumazet-laptop>
References: <4F742AE4.6050006@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "zhuangfeiran@ict.ac.cn" <zhuangfeiran@ict.ac.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55282 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2C2Lpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 07:45:47 -0400
In-Reply-To: <4F742AE4.6050006@ict.ac.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 mars 2012 =C3=A0 17:27 +0800, zhuangfeiran@ict.ac.cn a =C3=A9=
crit :
> When K >=3D 0xFFFF0000, AND needs the two least significant bytes of =
K as
> its operand, but EMIT2() gives it the least significant byte of K and
> 0x2. EMIT() should be used here to replace EMIT2().
>=20
> Signed-off-by: Feiran Zhuang  <zhuangfeiran@ict.ac.cn>
> ---
>  arch/x86/net/bpf_jit_comp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.=
c
> index 5671752..5a5b6e4 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -289,7 +289,7 @@ void bpf_jit_compile(struct sk_filter *fp)
>  					EMIT2(0x24, K & 0xFF); /* and imm8,%al */
>  				} else if (K >=3D 0xFFFF0000) {
>  					EMIT2(0x66, 0x25);	/* and imm16,%ax */
> -					EMIT2(K, 2);
> +					EMIT(K, 2);
>  				} else {
>  					EMIT1_off32(0x25, K);	/* and imm32,%eax */
>  				}

Good catch, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
