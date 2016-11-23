From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of     e1000_hw->hw_addr
Date: Wed, 23 Nov 2016 23:48:52 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81FDE478@ORSMSX101.amr.corp.intel.com>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Cao jin <caoj.fnst@cn.fujitsu.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on behalf of Cao jin [caoj.fnst@cn.fujitsu.com]
> Sent: Monday, November 07, 2016 11:06 PM
To> : linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Cc: izumi.taku@jp.fujitsu.com; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead of     e1000_hw->hw_addr
> 
> When running as guest, under certain condition, it will oops as following.
> writel() in igb_configure_tx_ring() results in oops, because hw->hw_addr
> is NULL. While other register access won't oops kernel because they use
> wr32/rd32 which have a defense against NULL pointer.
> 
>     [  141.225449] pcieport 0000:00:1c.0: AER: Multiple Uncorrected (Fatal)
>     error received: id=0101
>     [  141.225523] igb 0000:01:00.1: PCIe Bus Error:
>     severity=Uncorrected (Fatal), type=Unaccessible,
>     id=0101(Unregistered Agent ID)
>     [  141.299442] igb 0000:01:00.1: broadcast error_detected message
>     [  141.300539] igb 0000:01:00.0 enp1s0f0: PCIe link lost, device now
>     detached
>     [  141.351019] igb 0000:01:00.1 enp1s0f1: PCIe link lost, device now
>     detached
>     [  143.465904] pcieport 0000:00:1c.0: Root Port link has been reset
>     [  143.465994] igb 0000:01:00.1: broadcast slot_reset message
>     [  143.466039] igb 0000:01:00.0: enabling device (0000 -> 0002)
>     [  144.389078] igb 0000:01:00.1: enabling device (0000 -> 0002)
>     [  145.312078] igb 0000:01:00.1: broadcast resume message
>     [  145.322211] BUG: unable to handle kernel paging request at
>     0000000000003818
>     [  145.361275] IP: [<ffffffffa02fd38d>]
>     igb_configure_tx_ring+0x14d/0x280 [igb]
>     [  145.400048] PGD 0
>     [  145.438007] Oops: 0002 [#1] SMP
> 
> A similiar issue & solution could be found at:
>     http://patchwork.ozlabs.org/patch/689592/
> 
> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
