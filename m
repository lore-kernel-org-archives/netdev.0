From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] r8152: simply the arguments
Date: Thu, 16 Mar 2017 14:28:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB29DA@AcuExch.aculab.com>
References: <1394712342-15778-253-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "nic_swsd@realtek.com" <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Hayes Wang' <hayeswang@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:51631 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751712AbdCPO2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 10:28:15 -0400
In-Reply-To: <1394712342-15778-253-Taiwan-albertk@realtek.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang
> Sent: 16 March 2017 06:28
> Replace &tp->napi with napi and tp->netdev with netdev.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 44 +++++++++++++++++++++++++++-----------------
>  1 file changed, 27 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 227e1fd..e480e9f 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -1761,6 +1761,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
>  	unsigned long flags;
>  	struct list_head *cursor, *next, rx_queue;
>  	int ret = 0, work_done = 0;
> +	struct napi_struct *napi = &tp->napi;
> 
>  	if (!skb_queue_empty(&tp->rx_queue)) {
>  		while (work_done < budget) {
> @@ -1773,7 +1774,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
>  				break;
> 
>  			pkt_len = skb->len;
> -			napi_gro_receive(&tp->napi, skb);
> +			napi_gro_receive(napi, skb);
...

I'm not sure this makes the code any more readable.
It isn't even needed to shorten any long lines.

If you are really lucky the compiler will optimise it away.
Otherwise it will generate another local variable and possibly
a register spill to stack.

	David
 
