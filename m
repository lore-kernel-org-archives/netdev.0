From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 3/9] powerpc32: checksum_wrappers_64 becomes
 checksum_wrappers
Date: Thu, 22 Oct 2015 22:26:33 -0500
Message-ID: <1445570793.701.147.camel@freescale.com>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
	 <91ebacbbd631ec02ad00e0a824b6cad0dac532a0.1442876807.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>, <anton@samba.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <91ebacbbd631ec02ad00e0a824b6cad0dac532a0.1442876807.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-22 at 16:34 +0200, Christophe Leroy wrote:
> The powerpc64 checksum wrapper functions adds csum_and_copy_to_user()
> which otherwise is implemented in include/net/checksum.h by using
> csum_partial() then copy_to_user()
> 
> Those two wrapper fonctions are also applicable to powerpc32 as it is
> based on the use of csum_partial_copy_generic() which also
> exists on powerpc32
> 
> This patch renames arch/powerpc/lib/checksum_wrappers_64.c to
> arch/powerpc/lib/checksum_wrappers.c and
> makes it non-conditional to CONFIG_WORD_SIZE
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  arch/powerpc/include/asm/checksum.h                              | 9 ------
> ---
>  arch/powerpc/lib/Makefile                                        | 3 +--
>  arch/powerpc/lib/{checksum_wrappers_64.c => checksum_wrappers.c} | 0
>  3 files changed, 1 insertion(+), 11 deletions(-)
>  rename arch/powerpc/lib/{checksum_wrappers_64.c => checksum_wrappers.c} 
> (100%)

I wonder why it was 64-bit specific in the first place.

CCing Anton Blanchard.  

-Scott

> 
> diff --git a/arch/powerpc/include/asm/checksum.h 
> b/arch/powerpc/include/asm/checksum.h
> index d2ca07b..afa6722 100644
> --- a/arch/powerpc/include/asm/checksum.h
> +++ b/arch/powerpc/include/asm/checksum.h
> @@ -47,21 +47,12 @@ extern __wsum csum_partial_copy_generic(const void 
> *src, void *dst,
>                                             int len, __wsum sum,
>                                             int *src_err, int *dst_err);
>  
> -#ifdef __powerpc64__
>  #define _HAVE_ARCH_COPY_AND_CSUM_FROM_USER
>  extern __wsum csum_and_copy_from_user(const void __user *src, void *dst,
>                                     int len, __wsum sum, int *err_ptr);
>  #define HAVE_CSUM_COPY_USER
>  extern __wsum csum_and_copy_to_user(const void *src, void __user *dst,
>                                   int len, __wsum sum, int *err_ptr);
> -#else
> -/*
> - * the same as csum_partial, but copies from src to dst while it
> - * checksums.
> - */
> -#define csum_partial_copy_from_user(src, dst, len, sum, errp)   \
> -        csum_partial_copy_generic((__force const void *)(src), (dst), 
> (len), (sum), (errp), NULL)
> -#endif
>  
>  #define csum_partial_copy_nocheck(src, dst, len, sum)   \
>          csum_partial_copy_generic((src), (dst), (len), (sum), NULL, NULL)
> diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
> index a47e142..e46b068 100644
> --- a/arch/powerpc/lib/Makefile
> +++ b/arch/powerpc/lib/Makefile
> @@ -22,8 +22,7 @@ obj64-$(CONFIG_SMP) += locks.o
>  obj64-$(CONFIG_ALTIVEC)      += vmx-helper.o
>  
>  ifeq ($(CONFIG_GENERIC_CSUM),)
> -obj-y                        += checksum_$(CONFIG_WORD_SIZE).o
> -obj-$(CONFIG_PPC64)  += checksum_wrappers_64.o
> +obj-y                        += checksum_$(CONFIG_WORD_SIZE).o checksum_wrappers.o
>  endif
>  
>  obj-$(CONFIG_PPC_EMULATE_SSTEP)      += sstep.o ldstfp.o
> diff --git a/arch/powerpc/lib/checksum_wrappers_64.c 
> b/arch/powerpc/lib/checksum_wrappers.c
> similarity index 100%
> rename from arch/powerpc/lib/checksum_wrappers_64.c
> rename to arch/powerpc/lib/checksum_wrappers.c
