From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] igbvf: clear buffer_info->dma after
	dma_unmap_single()
Date: Thu, 13 Aug 2015 01:48:30 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81AE47C6@ORSMSX101.amr.corp.intel.com>
References: <1438846337-6164-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Assmann <sassmann@kpanic.de>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49504 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbbHMBsc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 21:48:32 -0400
In-Reply-To: <1438846337-6164-1-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Stefan Assmann
> Sent: Thursday, August 06, 2015 12:32 AM
> To: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org; sassmann@kpanic.de
> Subject: [Intel-wired-lan] [PATCH] igbvf: clear buffer_info->dma after
> dma_unmap_single()
> 
> The driver doesn't clear buffer_info->dma after calling
> dma_unmap_single() in all cases. This has been discovered by changing
> the mtu twice, which caused the following backtrace.
> 
> [   68.569280] WARNING: CPU: 2 PID: 1860 at drivers/iommu/intel-
> iommu.c:3517 intel_unmap+0x20c/0x220()
> [   68.579392] Driver unmaps unmatched page at PFN fffc2a40
> [   68.585322] Modules linked in: igbvf ipt_MASQUERADE
> nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat kvm_intel kvm igb
> megs
> [   68.599163] CPU: 2 PID: 1860 Comm: ifconfig Not tainted 4.2.0-rc4+ #147
> [   68.606543] Hardware name: IBM  -[546025Z]-/00Y7630, BIOS -[VVE134TUS-
> 1.51]- 10/17/2013
> [   68.615473]  0000000000000dbd ffff88046441bb08 ffffffff81a5ad0b
> ffffffff81e2f9ea
> [   68.623775]  ffff88046441bb58 ffff88046441bb48 ffffffff81056b55
> ffff88047fc583c0
> [   68.632075]  0000000000000000 ffff880469a8e600 00000000fffc2a40
> ffff880465b32098
> [   68.640375] Call Trace:
> [   68.643109]  [<ffffffff81a5ad0b>] dump_stack+0x48/0x5d
> [   68.648844]  [<ffffffff81056b55>] warn_slowpath_common+0x95/0xe0
> [   68.655549]  [<ffffffff81056c56>] warn_slowpath_fmt+0x46/0x70
> [   68.661960]  [<ffffffff8158a614>] ? find_iova+0x54/0x90
> [   68.667791]  [<ffffffff815988dc>] intel_unmap+0x20c/0x220
> [   68.673815]  [<ffffffff8159891e>] intel_unmap_page+0xe/0x10
> [   68.680038]  [<ffffffffa0067536>] igbvf_clean_rx_ring+0x96/0x370
> [igbvf]
> [   68.687516]  [<ffffffffa0067915>] igbvf_down+0x105/0x110 [igbvf]
> [   68.694219]  [<ffffffffa0067beb>] igbvf_change_mtu+0x16b/0x180 [igbvf]
> [...]
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 1 +
>  1 file changed, 1 insertion(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
