From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] liquidio: make VF driver notify NIC
 firmware of MTU change
Date: Mon, 21 Aug 2017 11:04:19 -0700 (PDT)
Message-ID: <20170821.110419.1444561309238985446.davem@davemloft.net>
References: <20170818183432.GA4487@felix-thinkpad.cavium.com>
        <20170818183520.GA4522@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753141AbdHUSEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 14:04:20 -0400
In-Reply-To: <20170818183520.GA4522@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 18 Aug 2017 11:35:20 -0700

> Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 22 ++++++++++++++++++----
>  1 file changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> index 0402b18..e947783 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> @@ -1545,13 +1545,27 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
>  static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
>  {
>  	struct lio *lio = GET_LIO(netdev);
> +	struct octeon_device *oct = lio->oct_dev;
> +	struct octnic_ctrl_pkt nctrl;
> +	int ret = 0;

Please order local variable declarations from longest to shortest line.
