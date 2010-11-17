From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 09:18:05 +0100
Message-ID: <1289981885.2687.4.camel@edumazet-laptop>
References: <20101110.102129.112602843.davem@davemloft.net>
	 <1289414024.2469.20.camel@edumazet-laptop>
	 <20101110.103807.39173013.davem@davemloft.net>
	 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
	 <1289915053.5372.183.camel@edumazet-laptop>
	 <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp>
	 <1289925055.5372.484.camel@edumazet-laptop>
	 <201011170119.oAH1JpES011121@www262.sakura.ne.jp>
	 <1289980137.2732.280.camel@edumazet-laptop>
	 <AANLkTimi1AhXnqv8991Y3=HwoYwvYxEbPd0LroGouZp9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mjt@tls.msk.ru,
	davem@davemloft.net, drosenberg@vsecurity.com, hagen@jauu.net,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46781 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934199Ab0KQISO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 03:18:14 -0500
Received: by wyb28 with SMTP id 28so1688663wyb.19
        for <netdev@vger.kernel.org>; Wed, 17 Nov 2010 00:18:13 -0800 (PST)
In-Reply-To: <AANLkTimi1AhXnqv8991Y3=HwoYwvYxEbPd0LroGouZp9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 novembre 2010 =C3=A0 15:54 +0800, Changli Gao a =C3=A9cr=
it :
> On Wed, Nov 17, 2010 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> >
> > Please repost it when Changli patch is accepted by David
> > (if accepted :)), to get rid of the "+ 1"
> >
>=20
> Oh. No need, if David accepts this patch first, otherwise, there is
> just some offset, and patch can handle it. :)
>=20
>=20


I was speaking of all the "+ 1" in codes[] init

+       static const u8 codes[] =3D {
+               [BPF_ALU|BPF_ADD|BPF_K]  =3D BPF_S_ALU_ADD_K + 1,
+               [BPF_ALU|BPF_ADD|BPF_X]  =3D BPF_S_ALU_ADD_X + 1,
+               [BPF_ALU|BPF_SUB|BPF_K]  =3D BPF_S_ALU_SUB_K + 1,
+               [BPF_ALU|BPF_SUB|BPF_X]  =3D BPF_S_ALU_SUB_X + 1,
+               [BPF_ALU|BPF_MUL|BPF_K]  =3D BPF_S_ALU_MUL_K + 1,
+               [BPF_ALU|BPF_MUL|BPF_X]  =3D BPF_S_ALU_MUL_X + 1,
+               [BPF_ALU|BPF_DIV|BPF_X]  =3D BPF_S_ALU_DIV_X + 1,
+               [BPF_ALU|BPF_AND|BPF_K]  =3D BPF_S_ALU_AND_K + 1,
+               [BPF_ALU|BPF_AND|BPF_X]  =3D BPF_S_ALU_AND_X + 1,
+               [BPF_ALU|BPF_OR|BPF_K]   =3D BPF_S_ALU_OR_K + 1,
+               [BPF_ALU|BPF_OR|BPF_X]   =3D BPF_S_ALU_OR_X + 1,
+               [BPF_ALU|BPF_LSH|BPF_K]  =3D BPF_S_ALU_LSH_K + 1,
+               [BPF_ALU|BPF_LSH|BPF_X]  =3D BPF_S_ALU_LSH_X + 1,
+               [BPF_ALU|BPF_RSH|BPF_K]  =3D BPF_S_ALU_RSH_K + 1,
+               [BPF_ALU|BPF_RSH|BPF_X]  =3D BPF_S_ALU_RSH_X + 1,
+               [BPF_ALU|BPF_NEG]        =3D BPF_S_ALU_NEG + 1,
+               [BPF_LD|BPF_W|BPF_ABS]   =3D BPF_S_LD_W_ABS + 1,
+               [BPF_LD|BPF_H|BPF_ABS]   =3D BPF_S_LD_H_ABS + 1,
+               [BPF_LD|BPF_B|BPF_ABS]   =3D BPF_S_LD_B_ABS + 1,
+               [BPF_LD|BPF_W|BPF_LEN]   =3D BPF_S_LD_W_LEN + 1,
+               [BPF_LD|BPF_W|BPF_IND]   =3D BPF_S_LD_W_IND + 1,
+               [BPF_LD|BPF_H|BPF_IND]   =3D BPF_S_LD_H_IND + 1,
+               [BPF_LD|BPF_B|BPF_IND]   =3D BPF_S_LD_B_IND + 1,
+               [BPF_LD|BPF_IMM]         =3D BPF_S_LD_IMM + 1,
+               [BPF_LDX|BPF_W|BPF_LEN]  =3D BPF_S_LDX_W_LEN + 1,
+               [BPF_LDX|BPF_B|BPF_MSH]  =3D BPF_S_LDX_B_MSH + 1,
+               [BPF_LDX|BPF_IMM]        =3D BPF_S_LDX_IMM + 1,
+               [BPF_MISC|BPF_TAX]       =3D BPF_S_MISC_TAX + 1,
+               [BPF_MISC|BPF_TXA]       =3D BPF_S_MISC_TXA + 1,
+               [BPF_RET|BPF_K]          =3D BPF_S_RET_K + 1,
+               [BPF_RET|BPF_A]          =3D BPF_S_RET_A + 1,
+               [BPF_ALU|BPF_DIV|BPF_K]  =3D BPF_S_ALU_DIV_K + 1,
+               [BPF_LD|BPF_MEM]         =3D BPF_S_LD_MEM + 1,
+               [BPF_LDX|BPF_MEM]        =3D BPF_S_LDX_MEM + 1,
+               [BPF_ST]                 =3D BPF_S_ST + 1,
+               [BPF_STX]                =3D BPF_S_STX + 1,
+               [BPF_JMP|BPF_JA]         =3D BPF_S_JMP_JA + 1,
+               [BPF_JMP|BPF_JEQ|BPF_K]  =3D BPF_S_JMP_JEQ_K + 1,
+               [BPF_JMP|BPF_JEQ|BPF_X]  =3D BPF_S_JMP_JEQ_X + 1,
+               [BPF_JMP|BPF_JGE|BPF_K]  =3D BPF_S_JMP_JGE_K + 1,
+               [BPF_JMP|BPF_JGE|BPF_X]  =3D BPF_S_JMP_JGE_X + 1,
+               [BPF_JMP|BPF_JGT|BPF_K]  =3D BPF_S_JMP_JGT_K + 1,
+               [BPF_JMP|BPF_JGT|BPF_X]  =3D BPF_S_JMP_JGT_X + 1,
+               [BPF_JMP|BPF_JSET|BPF_K] =3D BPF_S_JMP_JSET_K + 1,
+               [BPF_JMP|BPF_JSET|BPF_X] =3D BPF_S_JMP_JSET_X + 1,
+       };

This was needed because the translated instructions were begining from =
0

If we change them to start at offset 1, we can avoid all the "+ 1" :

and avoid the bit ugly :

if (!code--) ...




