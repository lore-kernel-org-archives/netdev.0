From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: cleanup codes[] init
Date: Fri, 19 Nov 2010 16:38:13 +0800
Message-ID: <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
 <b2c34db84e88366e465af590900ae3db@localhost> <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
 <1290153111.29509.2.camel@edumazet-laptop> <1290153398.29509.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37229 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab0KSIif convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 03:38:35 -0500
Received: by fxm13 with SMTP id 13so451279fxm.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 00:38:34 -0800 (PST)
In-Reply-To: <1290153398.29509.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 3:56 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Starting the translated instruction to 1 instead of 0 allows us to
> remove one descrement at check time and makes codes[] array init
> cleaner.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0net/core/filter.c | =A0 95 +++++++++++++++++++++------------------=
-----
> =A01 file changed, 47 insertions(+), 48 deletions(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 15a545d..a1edb5d 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -39,7 +39,7 @@
> =A0#include <linux/filter.h>
>
> =A0enum {
> - =A0 =A0 =A0 BPF_S_RET_K =3D 0,
> + =A0 =A0 =A0 BPF_S_RET_K =3D 1,
> =A0 =A0 =A0 =A0BPF_S_RET_A,
> =A0 =A0 =A0 =A0BPF_S_ALU_ADD_K,
> =A0 =A0 =A0 =A0BPF_S_ALU_ADD_X,
> @@ -436,51 +436,51 @@ int sk_chk_filter(struct sock_filter *filter, i=
nt flen)
> =A0 =A0 =A0 =A0 * Invalid instructions are initialized to 0.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0static const u8 codes[] =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_ADD|BPF_K] =A0=3D BPF_S_AL=
U_ADD_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_ADD|BPF_X] =A0=3D BPF_S_AL=
U_ADD_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_SUB|BPF_K] =A0=3D BPF_S_AL=
U_SUB_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_SUB|BPF_X] =A0=3D BPF_S_AL=
U_SUB_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_MUL|BPF_K] =A0=3D BPF_S_AL=
U_MUL_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_MUL|BPF_X] =A0=3D BPF_S_AL=
U_MUL_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_DIV|BPF_X] =A0=3D BPF_S_AL=
U_DIV_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_AND|BPF_K] =A0=3D BPF_S_AL=
U_AND_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_AND|BPF_X] =A0=3D BPF_S_AL=
U_AND_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_OR|BPF_K] =A0 =3D BPF_S_AL=
U_OR_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_OR|BPF_X] =A0 =3D BPF_S_AL=
U_OR_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_LSH|BPF_K] =A0=3D BPF_S_AL=
U_LSH_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_LSH|BPF_X] =A0=3D BPF_S_AL=
U_LSH_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_RSH|BPF_K] =A0=3D BPF_S_AL=
U_RSH_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_RSH|BPF_X] =A0=3D BPF_S_AL=
U_RSH_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_NEG] =A0 =A0 =A0 =A0=3D BP=
=46_S_ALU_NEG + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_ABS] =A0 =3D BPF_S_LD=
_W_ABS + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_H|BPF_ABS] =A0 =3D BPF_S_LD=
_H_ABS + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_B|BPF_ABS] =A0 =3D BPF_S_LD=
_B_ABS + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_LEN] =A0 =3D BPF_S_LD=
_W_LEN + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_IND] =A0 =3D BPF_S_LD=
_W_IND + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_H|BPF_IND] =A0 =3D BPF_S_LD=
_H_IND + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_B|BPF_IND] =A0 =3D BPF_S_LD=
_B_IND + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_IMM] =A0 =A0 =A0 =A0 =3D BP=
=46_S_LD_IMM + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_W|BPF_LEN] =A0=3D BPF_S_LD=
X_W_LEN + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_B|BPF_MSH] =A0=3D BPF_S_LD=
X_B_MSH + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_IMM] =A0 =A0 =A0 =A0=3D BP=
=46_S_LDX_IMM + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_MISC|BPF_TAX] =A0 =A0 =A0 =3D BPF_=
S_MISC_TAX + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_MISC|BPF_TXA] =A0 =A0 =A0 =3D BPF_=
S_MISC_TXA + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_RET|BPF_K] =A0 =A0 =A0 =A0 =A0=3D =
BPF_S_RET_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_RET|BPF_A] =A0 =A0 =A0 =A0 =A0=3D =
BPF_S_RET_A + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_DIV|BPF_K] =A0=3D BPF_S_AL=
U_DIV_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_MEM] =A0 =A0 =A0 =A0 =3D BP=
=46_S_LD_MEM + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_MEM] =A0 =A0 =A0 =A0=3D BP=
=46_S_LDX_MEM + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ST] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D BPF_S_ST + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_STX] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
=3D BPF_S_STX + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JA] =A0 =A0 =A0 =A0 =3D BP=
=46_S_JMP_JA + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JEQ|BPF_K] =A0=3D BPF_S_JM=
P_JEQ_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JEQ|BPF_X] =A0=3D BPF_S_JM=
P_JEQ_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGE|BPF_K] =A0=3D BPF_S_JM=
P_JGE_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGE|BPF_X] =A0=3D BPF_S_JM=
P_JGE_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGT|BPF_K] =A0=3D BPF_S_JM=
P_JGT_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGT|BPF_X] =A0=3D BPF_S_JM=
P_JGT_X + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JSET|BPF_K] =3D BPF_S_JMP_=
JSET_K + 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JSET|BPF_X] =3D BPF_S_JMP_=
JSET_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_ADD|BPF_K] =A0=3D BPF_S_AL=
U_ADD_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_ADD|BPF_X] =A0=3D BPF_S_AL=
U_ADD_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_SUB|BPF_K] =A0=3D BPF_S_AL=
U_SUB_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_SUB|BPF_X] =A0=3D BPF_S_AL=
U_SUB_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_MUL|BPF_K] =A0=3D BPF_S_AL=
U_MUL_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_MUL|BPF_X] =A0=3D BPF_S_AL=
U_MUL_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_DIV|BPF_X] =A0=3D BPF_S_AL=
U_DIV_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_AND|BPF_K] =A0=3D BPF_S_AL=
U_AND_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_AND|BPF_X] =A0=3D BPF_S_AL=
U_AND_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_OR|BPF_K] =A0 =3D BPF_S_AL=
U_OR_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_OR|BPF_X] =A0 =3D BPF_S_AL=
U_OR_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_LSH|BPF_K] =A0=3D BPF_S_AL=
U_LSH_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_LSH|BPF_X] =A0=3D BPF_S_AL=
U_LSH_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_RSH|BPF_K] =A0=3D BPF_S_AL=
U_RSH_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_RSH|BPF_X] =A0=3D BPF_S_AL=
U_RSH_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_NEG] =A0 =A0 =A0 =A0=3D BP=
=46_S_ALU_NEG,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_ABS] =A0 =3D BPF_S_LD=
_W_ABS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_H|BPF_ABS] =A0 =3D BPF_S_LD=
_H_ABS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_B|BPF_ABS] =A0 =3D BPF_S_LD=
_B_ABS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_LEN] =A0 =3D BPF_S_LD=
_W_LEN,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_IND] =A0 =3D BPF_S_LD=
_W_IND,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_H|BPF_IND] =A0 =3D BPF_S_LD=
_H_IND,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_B|BPF_IND] =A0 =3D BPF_S_LD=
_B_IND,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_IMM] =A0 =A0 =A0 =A0 =3D BP=
=46_S_LD_IMM,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_W|BPF_LEN] =A0=3D BPF_S_LD=
X_W_LEN,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_B|BPF_MSH] =A0=3D BPF_S_LD=
X_B_MSH,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_IMM] =A0 =A0 =A0 =A0=3D BP=
=46_S_LDX_IMM,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_MISC|BPF_TAX] =A0 =A0 =A0 =3D BPF_=
S_MISC_TAX,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_MISC|BPF_TXA] =A0 =A0 =A0 =3D BPF_=
S_MISC_TXA,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_RET|BPF_K] =A0 =A0 =A0 =A0 =A0=3D =
BPF_S_RET_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_RET|BPF_A] =A0 =A0 =A0 =A0 =A0=3D =
BPF_S_RET_A,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_DIV|BPF_K] =A0=3D BPF_S_AL=
U_DIV_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_MEM] =A0 =A0 =A0 =A0 =3D BP=
=46_S_LD_MEM,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_MEM] =A0 =A0 =A0 =A0=3D BP=
=46_S_LDX_MEM,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ST] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D BPF_S_ST,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_STX] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
=3D BPF_S_STX,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JA] =A0 =A0 =A0 =A0 =3D BP=
=46_S_JMP_JA,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JEQ|BPF_K] =A0=3D BPF_S_JM=
P_JEQ_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JEQ|BPF_X] =A0=3D BPF_S_JM=
P_JEQ_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGE|BPF_K] =A0=3D BPF_S_JM=
P_JGE_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGE|BPF_X] =A0=3D BPF_S_JM=
P_JGE_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGT|BPF_K] =A0=3D BPF_S_JM=
P_JGT_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGT|BPF_X] =A0=3D BPF_S_JM=
P_JGT_X,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JSET|BPF_K] =3D BPF_S_JMP_=
JSET_K,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JSET|BPF_X] =3D BPF_S_JMP_=
JSET_X,
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0int pc;
>
> @@ -495,8 +495,7 @@ int sk_chk_filter(struct sock_filter *filter, int=
 flen)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (code >=3D ARRAY_SIZE(codes))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0code =3D codes[code];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Undo the '+ 1' in codes[] after vali=
dation. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!code--)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!code)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Some instructions need special chec=
ks */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (code) {
>
>
>

I compared the asm code of sk_run_filter.

Here is the original:

                switch (fentry->code) {
ffffffff8138c70c:       66 83 38 2c             cmpw   $0x2c,(%rax)
        /*
         * Process array of filter instructions.
         */
        for (pc =3D 0; pc < flen; pc++) {
                const struct sock_filter *fentry =3D &filter[pc];
                u32 f_k =3D fentry->k;
ffffffff8138c710:       44 8b 78 04             mov    0x4(%rax),%r15d

                switch (fentry->code) {
ffffffff8138c714:       0f 87 53 02 00 00       ja
ffffffff8138c96d <sk_run_filter+0x2a8>
ffffffff8138c71a:       0f b7 10                movzwl (%rax),%edx
ffffffff8138c71d:       ff 24 d5 00 00 00 00    jmpq   *0x0(,%rdx,8)

And here is the patched:

                switch (fentry->code) {
ffffffff8138c708:       8b 10                   mov    (%rax),%edx
        /*
         * Process array of filter instructions.
         */
        for (pc =3D 0; pc < flen; pc++) {
                const struct sock_filter *fentry =3D &filter[pc];
                u32 f_k =3D fentry->k;
ffffffff8138c70a:       44 8b 78 04             mov    0x4(%rax),%r15d

                switch (fentry->code) {
ffffffff8138c70e:       ff ca                   dec    %edx
ffffffff8138c710:       66 83 fa 2c             cmp    $0x2c,%dx
ffffffff8138c714:       0f 87 53 02 00 00       ja
ffffffff8138c96d <sk_run_filter+0x2ac>
ffffffff8138c71a:       0f b7 d2                movzwl %dx,%edx
ffffffff8138c71d:       ff 24 d5 00 00 00 00    jmpq   *0x0(,%rdx,8)

As you see, an additional 'dec %edx' instruction is inserted.
sk_chk_filter() only runs 1 times, I think we can afford the 'dec
instruction' and 'dirty' code, but sk_run_filter() runs much often,
this additional dec instruction isn't affordable.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
