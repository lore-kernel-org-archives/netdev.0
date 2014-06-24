From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT
 test
Date: Tue, 24 Jun 2014 18:23:06 +0400
Message-ID: <53A989CA.9030405@cogentembedded.com>
References: <1403603969-24436-1-git-send-email-kda@linux-powerpc.org> <1403603969-24436-2-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org
To: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:49982 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbaFXOXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 10:23:05 -0400
Received: by mail-lb0-f177.google.com with SMTP id u10so536907lbd.22
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 07:23:03 -0700 (PDT)
In-Reply-To: <1403603969-24436-2-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/24/2014 01:59 PM, Denis Kirjanov wrote:

> We have to return the boolean here if the tag presents
> or not, not jusr ORing the TCI with the mask which results to:

> [  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
> [  709.412245] ret 4096 != 1
> [  709.412332] ret 4096 != 1
> [  709.412333] FAIL (2 times)

    You need to sign off on the patch, else it won't be applied.

> ---
>   arch/powerpc/net/bpf_jit_comp.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

> diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> index af0ed4d..a3d8f58 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -394,8 +394,10 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
>   							  vlan_tci));
>   			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
>   				PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
> -			else
> +			else {

    All arms of the *if* statement should have {} if one branch has {}.

>   				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
> +				PPC_SRWI(r_A, r_A, 12);
> +			}
>   			break;
>   		case BPF_ANC | SKF_AD_QUEUE:
>   			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,

WBR, Sergei
