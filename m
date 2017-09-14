From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next v3] e1000e: Be drop monitor
        friendly
Date: Thu, 14 Sep 2017 23:54:52 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C6A057B@ORSMSX101.amr.corp.intel.com>
References: <20170826011424.27251-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "edumazet@gmail.com" <edumazet@gmail.com>,
        open list <linux-kernel@vger.kernel.org>,
        "moderated list:INTEL ETHERNET DRIVERS"
        <intel-wired-lan@lists.osuosl.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170826011424.27251-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> Of Florian Fainelli
> Sent: Friday, August 25, 2017 6:14 PM
> To: netdev@vger.kernel.org
> Cc: edumazet@gmail.com; Florian Fainelli <f.fainelli@gmail.com>; open list
> <linux-kernel@vger.kernel.org>; moderated list:INTEL ETHERNET DRIVERS
> <intel-wired-lan@lists.osuosl.org>; davem@davemloft.net
> Subject: [Intel-wired-lan] [PATCH net-next v3] e1000e: Be drop monitor
> friendly
> 
> e1000e_put_txbuf() can be called from normal reclamation path as well as
> when a DMA mapping failure, so we need to differentiate these two cases
> when freeing SKBs to be drop monitor friendly. e1000e_tx_hwtstamp_work()
> and e1000_remove() are processing TX timestamped SKBs and those should
> not be accounted as drops either.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v3:
> 
> - differentiate normal reclamation from TX DMA fragment mapping errors
> - removed a few invalid dev_kfree_skb() replacements (those are already
>   drop monitor friendly)
> 
> Changes in v2:
> 
> - make it compile
> 
>  drivers/net/ethernet/intel/e1000e/netdev.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
