From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH] drivers/net/wireless/ath/wil6210: Makefile, only -Werror when no -W* in EXTRA_CFLAGS
Date: Wed, 27 Feb 2013 10:45:26 +0200
Message-ID: <1385870.TegBXpTM9i@lx-vladimir>
References: <512DADCA.9040609@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <wil6210@qca.qualcomm.com>,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth01.qualcomm.com ([65.197.215.72]:62951 "EHLO
	sabertooth01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755697Ab3B0Ipk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 03:45:40 -0500
In-Reply-To: <512DADCA.9040609@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, February 27, 2013 02:55:06 PM Chen Gang wrote:
> 
>   When make with EXTRA_CFLAGS=-W, it will report error.
>   so give a check in Makefile.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  drivers/net/wireless/ath/wil6210/Makefile |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/wil6210/Makefile b/drivers/net/wireless/ath/wil6210/Makefile
> index 9396dc9..d288eea 100644
> --- a/drivers/net/wireless/ath/wil6210/Makefile
> +++ b/drivers/net/wireless/ath/wil6210/Makefile
> @@ -9,5 +9,7 @@ wil6210-objs += wmi.o
>  wil6210-objs += interrupt.o
>  wil6210-objs += txrx.o
>  
> -subdir-ccflags-y += -Werror
> +ifeq (, $(findstring -W,$(EXTRA_CFLAGS)))
> +	subdir-ccflags-y += -Werror
> +endif
>  subdir-ccflags-y += -D__CHECK_ENDIAN__
> 
Acked-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>

Well, agree; -W triggers lots of warnings, I suspect all other places that use
-Werror should be problematic. Worth fixing all others? Quick look for v3.8 raises:

linux$ find . -name Makefile | xargs grep -e -Werror
./arch/sh/lib/Makefile:ccflags-y := -Werror
./arch/sh/kernel/Makefile:ccflags-y := -Werror
./arch/sh/mm/Makefile:ccflags-y := -Werror
./arch/sh/cchips/hd6446x/Makefile:ccflags-y := -Werror
./arch/sparc/prom/Makefile:ccflags := -Werror
./arch/sparc/lib/Makefile:ccflags-y := -Werror
./arch/sparc/kernel/Makefile:ccflags-y := -Werror
./arch/sparc/mm/Makefile:ccflags-y := -Werror
./arch/alpha/lib/Makefile:ccflags-y := -Werror
./arch/alpha/oprofile/Makefile:ccflags-y := -Werror -Wno-sign-compare
./arch/alpha/mm/Makefile:ccflags-y := -Werror
./arch/powerpc/kvm/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/lib/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/kernel/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/oprofile/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/xmon/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/mm/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/sysdev/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/sysdev/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/sysdev/xics/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/platforms/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./arch/powerpc/perf/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
./Makefile:                -Werror-implicit-function-declaration \
./tools/perf/Makefile:  CFLAGS_WERROR := -Werror
./tools/perf/Makefile:ifeq ($(call try-cc,$(SOURCE_HELLO),$(CFLAGS) -Werror -fstack-protector-all,-fstack-protector-all),y)
./tools/perf/Makefile:ifeq ($(call try-cc,$(SOURCE_HELLO),$(CFLAGS) -Werror -Wstack-protector,-Wstack-protector),y)
./tools/perf/Makefile:ifeq ($(call try-cc,$(SOURCE_HELLO),$(CFLAGS) -Werror -Wvolatile-register-var,-Wvolatile-register-var),y)
./drivers/scsi/lpfc/Makefile:ccflags-y += -Werror
./drivers/scsi/aic7xxx/Makefile:ccflags-y += -Werror
./drivers/staging/omapdrm/Makefile:ccflags-y := -Iinclude/drm -Werror
./drivers/net/wireless/ath/wil6210/Makefile:subdir-ccflags-y += -Werror
