From: Jonathan Toppins <jtoppins-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Mon, 12 Dec 2016 11:54:30 -0500
Message-ID: <9cf03e2b-a16d-19ec-a8ce-14f24272bf6a@redhat.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Reply-To: jtoppins-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/09/2016 01:47 AM, Selvin Xavier wrote:
> This series introduces the RoCE driver for the Broadcom
> NetXtreme-E 10/25/40/50 gigabit RoCE HCAs. 
> This driver is dependent on the bnxt_en NIC driver and is 
> based on the bnxt_re branch in Doug's repository. bnxt_en changes
> required for this patch series is already available in this branch.
> 
> I am preparing a git repository with these changes as per Jason's
> comment and will share the details later today.
> 
> v1-> v2:
>   * The license text in each file updated to reflect Dual license.
>   * Makefile and Kconfig changes are pushed to the last patch
>   * Moved bnxt_re_uverbs_abi.h to include/uapi/rdma folder
>   * Remove duplicate structure definitions from bnxt_re_hsi.h as
>     it is available in the corresponding bnxt_en header file (bnxt_hsi.h)
>   * Removed some unused code reported during code review.
>   * Fixed few sparse warnings
> 

I get the following sparse errors (filtered for only bnxt_re ones),
please let me know if they are false positives:

$ make C=2  drivers/net/ethernet/broadcom/bnxt/bnxt_en.ko
drivers/infiniband/hw/bnxtre/bnxt_re.ko
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHECK   arch/x86/purgatory/purgatory.c
[...]
  CHECK   arch/x86/purgatory/sha256.c
  CHECK   arch/x86/purgatory/string.c
[...]
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHECK   scripts/mod/empty.c
  CHECK   drivers/net/ethernet/broadcom/bnxt/bnxt.c
  CHECK   drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
  CHECK   drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
  CHECK   drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
  CHECK   drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
  MODPOST 2 modules
  CHECK   drivers/infiniband/hw/bnxtre/bnxt_re_main.c
  CHECK   drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
[...]
  CHECK   drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.c
  CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c:729:6: warning: symbol
'bnxt_qplib_cleanup_pkey_tbl' was not declared. Should it be static?
  CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
  CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
  CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c:1015:22: warning: context
imbalance in 'bnxt_qplib_lock_cqs' - wrong count at exit
drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c:1030:28: warning: context
imbalance in 'bnxt_qplib_unlock_cqs' - unexpected unlock
  MODPOST 2 modules

-Jon
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
