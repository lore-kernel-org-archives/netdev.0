From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
Date: Tue, 3 Jul 2012 13:04:26 +0000
Message-ID: <157393863283F442885425D2C454285623DB7BEC@NASANEXD02A.na.qualcomm.com>
References: <1341322056-26582-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341322056-26582-1-git-send-email-cjren@qca.qualcomm.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cloud,  why your patch contains :  'From: Cloud Ren <cjren@qca.qualcomm.com>'
I don't find it in other people's patch.

Doesn't David Miller think your time is wrong ?


> -----Original Message-----
> From: Ren, Cloud
> Sent: Tuesday, July 03, 2012 21:28
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Cc: qca-linux-team; nic-devel; Ren, Cloud
> Subject: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
> 
> From: Cloud Ren <cjren@qca.qualcomm.com>
> 
> some people report atl1c could cause system hang with following kernel trace
> info:
> ---------------------------------------
> WARNING: at.../net/sched/sch_generic.c:258 dev_watchdog+0x1db/0x1d0() ...
> NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out ...
> ---------------------------------------
> This is caused by netif_stop_queue calling when cable Link is down.
> So remove netif_stop_queue, because link_watch will take it over.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
> ---
>  drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 85717cb..7901831 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -261,7 +261,6 @@ static void atl1c_check_link_status(struct
> atl1c_adapter *adapter)
>  	if ((phy_data & BMSR_LSTATUS) == 0) {
>  		/* link down */
>  		netif_carrier_off(netdev);
> -		netif_stop_queue(netdev);
>  		hw->hibernate = true;
>  		if (atl1c_reset_mac(hw) != 0)
>  			if (netif_msg_hw(adapter))
> --
> 1.7.7
