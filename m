From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/2] powerpc: bpf: Use correct mask while accessing the
 VLAN tag
Date: Tue, 24 Jun 2014 08:29:46 -0700
Message-ID: <CAADnVQJPoy_z-WoqEXnSvTZ-ussCRawn9L5eBfo6S_gxY2MMwQ@mail.gmail.com>
References: <1403603969-24436-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev@lists.ozlabs.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:46877 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187AbaFXP35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:29:57 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so413224qgd.33
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:29:56 -0700 (PDT)
In-Reply-To: <1403603969-24436-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 2:59 AM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> Use the proper mask which is 0xefff

sob is missing.

also please expand the commit message a bit, otherwise it's too cryptic for
folks who don't know bpf details.

> ---
>  arch/powerpc/net/bpf_jit_comp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> index 6dcdade..af0ed4d 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -393,7 +393,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
>                         PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
>                                                           vlan_tci));
>                         if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
> -                               PPC_ANDI(r_A, r_A, VLAN_VID_MASK);
> +                               PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
>                         else
>                                 PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
>                         break;
> --
> 2.0.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
