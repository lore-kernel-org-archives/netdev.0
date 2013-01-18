From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH v2] net: fix wrong length of mac address
Date: Fri, 18 Jan 2013 01:00:35 -0800
Message-ID: <20130118090035.GB11088@ppwaskie-mobl2.amr.corp.intel.com>
References: <1358495514-18047-1-git-send-email-kongjianjun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kys@microsoft.com, haiyangz@microsoft.com,
	netdev@vger.kernel.org, devel@linuxdriverproject.org
To: Amos Kong <kongjianjun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63110 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844Ab3ARJAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 04:00:53 -0500
Content-Disposition: inline
In-Reply-To: <1358495514-18047-1-git-send-email-kongjianjun@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 03:51:54PM +0800, Amos Kong wrote:
> Typo, it should be ETH_ALEN.
> 
> Signed-off-by: Amos Kong <kongjianjun@gmail.com>
> ---
> v2: update commitlog, fix cc list
> ---
>  drivers/net/hyperv/netvsc_drv.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index f825a62..8264f0e 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -349,7 +349,7 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
>  	struct net_device_context *ndevctx = netdev_priv(ndev);
>  	struct hv_device *hdev =  ndevctx->device_ctx;
>  	struct sockaddr *addr = p;
> -	char save_adr[14];
> +	char save_adr[ETH_ALEN];
>  	unsigned char save_aatype;
>  	int err;

While you're at it, you should fix drivers/net/hyperv/hyperv_net.h:

struct netvsc_device_info {
>>>     unsigned char mac_adr[6];
        bool link_state;        /* 0 - link up, 1 - link down */
        int  ring_size;
};

Cheers,
-PJ
