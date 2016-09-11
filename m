From: Jarkko Sakkinen <jarkko.sakkinen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 00/26] constify local structures
Date: Sun, 11 Sep 2016 20:21:05 +0300
Message-ID: <20160911172105.GB5493@intel.com>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tatyana Nikolova <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tpmdd-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shiraz Saleem <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
To: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <tpmdd-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473599168-30561-1-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tpmdd-devel>,
	<mailto:tpmdd-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tpmdd-devel>
List-Post: <mailto:tpmdd-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:tpmdd-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tpmdd-devel>,
	<mailto:tpmdd-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: tpmdd-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 11, 2016 at 03:05:42PM +0200, Julia Lawall wrote:
> Constify local structures.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)

Just my two cents but:

1. You *can* use a static analysis too to find bugs or other issues.
2. However, you should manually do the commits and proper commit
   messages to subsystems based on your findings. And I generally think
   that if one contributes code one should also at least smoke test changes
   somehow.

I don't know if I'm alone with my opinion. I just think that one should
also do the analysis part and not blindly create and submit patches.

Anyway, I'll apply the TPM change at some point. As I said they were
for better. Thanks.

/Jarkko

> // <smpl>
> // The first rule ignores some cases that posed problems
> @r disable optional_qualifier@
> identifier s != {peri_clk_data,threshold_attr,tracer_flags,tracer};
> identifier i != {s5k5baf_cis_rect,smtcfb_fix};
> position p;
> @@
> static struct s i@p = { ... };
> 
> @lstruct@
> identifier r.s;
> @@
> struct s { ... };
> 
> @used depends on lstruct@
> identifier r.i;
> @@
> i
> 
> @bad1@
> expression e;
> identifier r.i;
> assignment operator a;
> @@
>  (<+...i...+>) a e
> 
> @bad2@
> identifier r.i;
> @@
>  &(<+...i...+>)
> 
> @bad3@
> identifier r.i;
> declarer d;
> @@
>  d(...,<+...i...+>,...);
> 
> @bad4@
> identifier r.i;
> type T;
> T[] e;
> identifier f;
> position p;
> @@
> 
> f@p(...,
> (
>   (<+...i...+>)
> &
>   e
> )
> ,...)
> 
> @bad4a@
> identifier r.i;
> type T;
> T *e;
> identifier f;
> position p;
> @@
> 
> f@p(...,
> (
>   (<+...i...+>)
> &
>   e
> )
> ,...)
> 
> @ok5@
> expression *e;
> identifier r.i;
> position p;
> @@
> e =@p i
> 
> @bad5@
> expression *e;
> identifier r.i;
> position p != ok5.p;
> @@
> e =@p (<+...i...+>)
> 
> @rr depends on used && !bad1 && !bad2 && !bad3 && !bad4 && !bad4a && !bad5@
> identifier s,r.i;
> position r.p;
> @@
> 
> static
> +const
>  struct s i@p = { ... };
> 
> @depends on used && !bad1 && !bad2 && !bad3 && !bad4 && !bad4a && !bad5
>  disable optional_qualifier@
> identifier rr.s,r.i;
> @@
> 
> static
> +const
>  struct s i;
> // </smpl>
> 
> ---
> 
>  drivers/acpi/acpi_apd.c                              |    8 +++---
>  drivers/char/tpm/tpm-interface.c                     |   10 ++++----
>  drivers/char/tpm/tpm-sysfs.c                         |    2 -
>  drivers/cpufreq/intel_pstate.c                       |    8 +++---
>  drivers/infiniband/hw/i40iw/i40iw_uk.c               |    6 ++---
>  drivers/media/i2c/tvp514x.c                          |    2 -
>  drivers/media/pci/ddbridge/ddbridge-core.c           |   18 +++++++--------
>  drivers/media/pci/ngene/ngene-cards.c                |   14 ++++++------
>  drivers/media/pci/smipcie/smipcie-main.c             |    8 +++---
>  drivers/misc/sgi-xp/xpc_uv.c                         |    2 -
>  drivers/net/arcnet/com20020-pci.c                    |   10 ++++----
>  drivers/net/can/c_can/c_can_pci.c                    |    4 +--
>  drivers/net/can/sja1000/plx_pci.c                    |   20 ++++++++---------
>  drivers/net/ethernet/mellanox/mlx4/main.c            |    4 +--
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |    2 -
>  drivers/net/ethernet/renesas/sh_eth.c                |   14 ++++++------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c     |    2 -
>  drivers/net/wireless/ath/dfs_pattern_detector.c      |    2 -
>  drivers/net/wireless/intel/iwlegacy/3945.c           |    4 +--
>  drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c  |    2 -
>  drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c  |    2 -
>  drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c  |    2 -
>  drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c  |    2 -
>  drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c  |    2 -
>  drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c  |    2 -
>  drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c  |    2 -
>  drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c  |    2 -
>  drivers/platform/chrome/chromeos_laptop.c            |   22 +++++++++----------
>  drivers/platform/x86/intel_scu_ipc.c                 |    6 ++---
>  drivers/platform/x86/intel_telemetry_debugfs.c       |    2 -
>  drivers/scsi/esas2r/esas2r_flash.c                   |    2 -
>  drivers/scsi/hptiop.c                                |    6 ++---
>  drivers/spi/spi-dw-pci.c                             |    4 +--
>  drivers/staging/rtl8192e/rtl8192e/rtl_core.c         |    2 -
>  drivers/usb/misc/ezusb.c                             |    2 -
>  drivers/video/fbdev/matrox/matroxfb_g450.c           |    2 -
>  lib/crc64_ecma.c                                     |    2 -
>  sound/pci/ctxfi/ctatc.c                              |    2 -
>  sound/pci/hda/patch_ca0132.c                         |   10 ++++----
>  sound/pci/riptide/riptide.c                          |    2 -
>  40 files changed, 110 insertions(+), 110 deletions(-)

------------------------------------------------------------------------------
