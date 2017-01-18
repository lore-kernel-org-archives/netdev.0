From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [PATCH 1/2] qed: Add support for hardware offloaded FCoE.
Date: Wed, 18 Jan 2017 15:26:20 -0800
Message-ID: <alpine.LRH.2.00.1701181524090.2548@mvluser05.qlc.com>
References: <201701172240.wF4OEtiC%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "Dupuis, Chad" <chad.dupuis@cavium.com>, <kbuild-all@01.org>,
        <martin.petersen@oracle.com>, <linux-scsi@vger.kernel.org>,
        <fcoe-devel@open-fcoe.org>, <netdev@vger.kernel.org>,
        <yuval.mintz@cavium.com>, <QLogic-Storage-Upstream@cavium.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0055.outbound.protection.outlook.com ([104.47.34.55]:62912
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751584AbdARX0b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 18:26:31 -0500
In-Reply-To: <201701172240.wF4OEtiC%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be addressed in v2 of the series. The warning pops up when 
CONFIG_DCB is not set. Thanks.

Regards,
-Arun

On Tue, 17 Jan 2017, 6:35am, kbuild test robot wrote:

> Hi Arun,
> 
> [auto build test WARNING on net-next/master]
> [also build test WARNING on v4.10-rc4 next-20170117]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Dupuis-Chad/Add-QLogic-FastLinQ-FCoE-qedf-driver/20170117-052438
> config: i386-randconfig-c0-01172134 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from drivers/net/ethernet/qlogic/qed/qed.h:49:0,
>                     from drivers/net/ethernet/qlogic/qed/qed_cxt.c:44:
> >> include/linux/qed/qed_if.h:428:37: warning: 'struct qed_dcbx_get' declared inside parameter list
>      void (*dcbx_aen)(void *dev, struct qed_dcbx_get *get, u32 mib_type);
>                                         ^
> >> include/linux/qed/qed_if.h:428:37: warning: its scope is only this definition or declaration, which is probably not what you want
> --
>    In file included from drivers/net/ethernet/qlogic/qed/qed.h:49:0,
>                     from drivers/net/ethernet/qlogic/qed/qed_dcbx.c:41:
> >> include/linux/qed/qed_if.h:428:37: warning: 'struct qed_dcbx_get' declared inside parameter list
>      void (*dcbx_aen)(void *dev, struct qed_dcbx_get *get, u32 mib_type);
>                                         ^
> >> include/linux/qed/qed_if.h:428:37: warning: its scope is only this definition or declaration, which is probably not what you want
>    drivers/net/ethernet/qlogic/qed/qed_dcbx.c: In function 'qed_dcbx_aen':
>    drivers/net/ethernet/qlogic/qed/qed_dcbx.c:873:42: error: 'struct qed_dcbx_info' has no member named 'get'
>       op->dcbx_aen(cookie, &hwfn->p_dcbx_info->get, mib_type);
>                                              ^
>    drivers/net/ethernet/qlogic/qed/qed_dcbx.c: In function 'qed_dcbx_mib_update_event':
>    drivers/net/ethernet/qlogic/qed/qed_dcbx.c:902:2: error: implicit declaration of function 'qed_dcbx_get_params' [-Werror=implicit-function-declaration]
>      qed_dcbx_get_params(p_hwfn, p_ptt, &p_hwfn->p_dcbx_info->get, type);
>      ^
>    drivers/net/ethernet/qlogic/qed/qed_dcbx.c:902:57: error: 'struct qed_dcbx_info' has no member named 'get'
>      qed_dcbx_get_params(p_hwfn, p_ptt, &p_hwfn->p_dcbx_info->get, type);
>                                                             ^
>    cc1: some warnings being treated as errors
> 
> vim +428 include/linux/qed/qed_if.h
> 
>    412		u8	name[QED_DRV_VER_STR_SIZE];
>    413	};
>    414	
>    415	#define ILT_PAGE_SIZE_TCFC 0x8000 /* 32KB */
>    416	
>    417	struct qed_int_info {
>    418		struct msix_entry	*msix;
>    419		u8			msix_cnt;
>    420	
>    421		/* This should be updated by the protocol driver */
>    422		u8			used_cnt;
>    423	};
>    424	
>    425	struct qed_common_cb_ops {
>    426		void	(*link_update)(void			*dev,
>    427				       struct qed_link_output	*link);
>  > 428		void	(*dcbx_aen)(void *dev, struct qed_dcbx_get *get, u32 mib_type);
>    429	};
>    430	
>    431	struct qed_selftest_ops {
>    432	/**
>    433	 * @brief selftest_interrupt - Perform interrupt test
>    434	 *
>    435	 * @param cdev
>    436	 *
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
