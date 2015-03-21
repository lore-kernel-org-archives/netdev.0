From: Hyong-Youb Kim <hkim@cspi.com>
Subject: Re: [PATCH v1 21/47] ethernet: myri10ge: use arch_phys_wc_add()
Date: Sat, 21 Mar 2015 16:08:00 +0900
Message-ID: <20150321070759.GB8766@gtest01.arcus>
References: <1426893517-2511-1-git-send-email-mcgrof@do-not-panic.com>
 <1426893517-2511-22-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <luto@amacapital.net>, <mingo@redhat.com>, <tglx@linutronix.de>,
	<hpa@zytor.com>, <jgross@suse.com>, <JBeulich@suse.com>,
	<bp@suse.de>, <suresh.b.siddha@intel.com>,
	<venkatesh.pallipadi@intel.com>, <airlied@redhat.com>,
	<linux-kernel@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<x86@kernel.org>, <xen-devel@lists.xenproject.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>, Ingo Molnar <mingo@elte.hu>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Hyong-Youb Kim <hykim@myri.com>, <netdev@vger.kernel.org>,
	Antonino Daplas <adaplas@gmail.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0144.outbound.protection.outlook.com ([157.55.234.144]:15437
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751132AbbCUHW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 03:22:58 -0400
Content-Disposition: inline
In-Reply-To: <1426893517-2511-22-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 04:18:11PM -0700, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> This driver already uses ioremap_wc() on the same range
> so when write-combining is available that will be used
> instead.
> 
[...]
> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
[...]
> @@ -1984,7 +1979,6 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
>  		data[i] = ((u64 *)&link_stats)[i];
>  
>  	data[i++] = (unsigned int)mgp->tx_boundary;
> -	data[i++] = (unsigned int)mgp->wc_enabled;
>  	data[i++] = (unsigned int)mgp->pdev->irq;
>  	data[i++] = (unsigned int)mgp->msi_enabled;
>  	data[i++] = (unsigned int)mgp->msix_enabled;

You would have to delete "WC from myri10ge_gstrings_main_stats too.
Something like below.  Thanks.

@@ -1905,7 +1905,7 @@ static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
 	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
 	"tx_heartbeat_errors", "tx_window_errors",
 	/* device-specific stats */
-	"tx_boundary", "WC", "irq", "MSI", "MSIX",
+	"tx_boundary", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
 #ifdef CONFIG_MYRI10GE_DCA
