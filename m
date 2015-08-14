From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH v2] e1000e: Modify tx/rx
 configurations to	avoid null pointer dereferences in e1000_open
Date: Fri, 14 Aug 2015 23:28:36 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81AE74F9@ORSMSX101.amr.corp.intel.com>
References: <1438769770-8887-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jia-Ju Bai <baijiaju1990@163.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438769770-8887-1-git-send-email-baijiaju1990@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Jia-Ju Bai
> Sent: Wednesday, August 05, 2015 3:16 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse
> Cc: netdev@vger.kernel.org; Jia-Ju Bai; intel-wired-lan@lists.osuosl.org;
> linux-kernel@vger.kernel.org
> Subject: [Intel-wired-lan] [PATCH v2] e1000e: Modify tx/rx configurations
> to avoid null pointer dereferences in e1000_open
> 
> When e1000e_setup_rx_resources is failed in e1000_open,
> e1000e_free_tx_resources in "err_setup_rx" segment is executed.
> "writel(0, tx_ring->head)" statement in e1000_clean_tx_ring
> in e1000e_free_tx_resources will cause a null poonter dereference(crash),
> because "tx_ring->head" is only assigned in e1000_configure_tx
> in e1000_configure, but it is after e1000e_setup_rx_resources.
> 
> This patch moves head/tail register writing to e1000_configure_tx/rx,
> which can fix this problem. It is inspired by igb_configure_tx_ring
> in the igb driver.
> 
> Specially, thank Alexander Duyck for his valuable suggestion.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |   24 ++++++++++++-----------
> -
>  1 file changed, 12 insertions(+), 12 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
