From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 1/8] arm: put types.h in uapi
Date: Fri, 13 Jan 2017 17:06:10 +0000
Message-ID: <20170113170610.GV14217@n2100.armlinux.org.uk>
References: <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
 <1484304406-10820-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie,
 daniel.vetter@ffwll.ch, linux-fbdev@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org,
 sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-am33-list@redhat.com,
 linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org,
 linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, hch@infradead.org,
 coreteam@netfilter.org, msalter@redhat.com, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org,
 linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 linux-xtensa@linux-xtensa.org, arnd@arndb.de, linux-kbuild@vger.kernel.org,
 adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, openri
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1484304406-10820-2-git-send-email-nicolas.dichtel@6wind.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2017 at 11:46:39AM +0100, Nicolas Dichtel wrote:
> This header file is exported, thus move it to uapi.

I'm taking this patch, but with the following commit log:

  Due to the way kbuild works, this header was unintentionally exported
  back in 2013 when it was created, despite it not being in a uapi/
  directory.  This is very non-intuitive behaviour by Kbuild.

  However, we've had this include exported to userland for almost four
  years, and searching google for "ARM types.h __UINTPTR_TYPE__" gives
  no hint that anyone has complained about it.  So, let's make it
  officially exported in this state.

If anyone has any objections, they better shout sooner rather than
later.

> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  arch/arm/include/asm/types.h      | 40 ---------------------------------------
>  arch/arm/include/uapi/asm/types.h | 40 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 40 insertions(+), 40 deletions(-)
>  delete mode 100644 arch/arm/include/asm/types.h
>  create mode 100644 arch/arm/include/uapi/asm/types.h
> 
> diff --git a/arch/arm/include/asm/types.h b/arch/arm/include/asm/types.h
> deleted file mode 100644
> index a53cdb8f068c..000000000000
> --- a/arch/arm/include/asm/types.h
> +++ /dev/null
> @@ -1,40 +0,0 @@
> -#ifndef _ASM_TYPES_H
> -#define _ASM_TYPES_H
> -
> -#include <asm-generic/int-ll64.h>
> -
> -/*
> - * The C99 types uintXX_t that are usually defined in 'stdint.h' are not as
> - * unambiguous on ARM as you would expect. For the types below, there is a
> - * difference on ARM between GCC built for bare metal ARM, GCC built for glibc
> - * and the kernel itself, which results in build errors if you try to build with
> - * -ffreestanding and include 'stdint.h' (such as when you include 'arm_neon.h'
> - * in order to use NEON intrinsics)
> - *
> - * As the typedefs for these types in 'stdint.h' are based on builtin defines
> - * supplied by GCC, we can tweak these to align with the kernel's idea of those
> - * types, so 'linux/types.h' and 'stdint.h' can be safely included from the same
> - * source file (provided that -ffreestanding is used).
> - *
> - *                    int32_t         uint32_t               uintptr_t
> - * bare metal GCC     long            unsigned long          unsigned int
> - * glibc GCC          int             unsigned int           unsigned int
> - * kernel             int             unsigned int           unsigned long
> - */
> -
> -#ifdef __INT32_TYPE__
> -#undef __INT32_TYPE__
> -#define __INT32_TYPE__		int
> -#endif
> -
> -#ifdef __UINT32_TYPE__
> -#undef __UINT32_TYPE__
> -#define __UINT32_TYPE__	unsigned int
> -#endif
> -
> -#ifdef __UINTPTR_TYPE__
> -#undef __UINTPTR_TYPE__
> -#define __UINTPTR_TYPE__	unsigned long
> -#endif
> -
> -#endif /* _ASM_TYPES_H */
> diff --git a/arch/arm/include/uapi/asm/types.h b/arch/arm/include/uapi/asm/types.h
> new file mode 100644
> index 000000000000..9435a42f575e
> --- /dev/null
> +++ b/arch/arm/include/uapi/asm/types.h
> @@ -0,0 +1,40 @@
> +#ifndef _UAPI_ASM_TYPES_H
> +#define _UAPI_ASM_TYPES_H
> +
> +#include <asm-generic/int-ll64.h>
> +
> +/*
> + * The C99 types uintXX_t that are usually defined in 'stdint.h' are not as
> + * unambiguous on ARM as you would expect. For the types below, there is a
> + * difference on ARM between GCC built for bare metal ARM, GCC built for glibc
> + * and the kernel itself, which results in build errors if you try to build with
> + * -ffreestanding and include 'stdint.h' (such as when you include 'arm_neon.h'
> + * in order to use NEON intrinsics)
> + *
> + * As the typedefs for these types in 'stdint.h' are based on builtin defines
> + * supplied by GCC, we can tweak these to align with the kernel's idea of those
> + * types, so 'linux/types.h' and 'stdint.h' can be safely included from the same
> + * source file (provided that -ffreestanding is used).
> + *
> + *                    int32_t         uint32_t               uintptr_t
> + * bare metal GCC     long            unsigned long          unsigned int
> + * glibc GCC          int             unsigned int           unsigned int
> + * kernel             int             unsigned int           unsigned long
> + */
> +
> +#ifdef __INT32_TYPE__
> +#undef __INT32_TYPE__
> +#define __INT32_TYPE__		int
> +#endif
> +
> +#ifdef __UINT32_TYPE__
> +#undef __UINT32_TYPE__
> +#define __UINT32_TYPE__	unsigned int
> +#endif
> +
> +#ifdef __UINTPTR_TYPE__
> +#undef __UINTPTR_TYPE__
> +#define __UINTPTR_TYPE__	unsigned long
> +#endif
> +
> +#endif /* _UAPI_ASM_TYPES_H */
> -- 
> 2.8.1
> 

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
