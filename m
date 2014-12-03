From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 5/6] myri10ge: use eth_skb_pad helper
Date: Wed, 03 Dec 2014 21:56:54 +0300
Message-ID: <547F5CF6.9010904@cogentembedded.com>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20> <20141203161758.9223.85476.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hyong-Youb Kim <hykim@myri.com>, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:58183 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaLCS46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 13:56:58 -0500
Received: by mail-lb0-f172.google.com with SMTP id u10so12891865lbd.3
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 10:56:57 -0800 (PST)
In-Reply-To: <20141203161758.9223.85476.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/03/2014 07:17 PM, Alexander Duyck wrote:

> Update myri10ge to use eth_skb_pad helper.  This also corrects a minor
> issue as the driver was updating length without updating the tail pointer.

> Cc: Hyong-Youb Kim <hykim@myri.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>   drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   15 +++++----------
>   1 file changed, 5 insertions(+), 10 deletions(-)

> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> index 9e7e3f1..af09905 100644
> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> @@ -2913,16 +2913,11 @@ again:
>   		flags |= MXGEFW_FLAGS_SMALL;
>
>   		/* pad frames to at least ETH_ZLEN bytes */
> -		if (unlikely(skb->len < ETH_ZLEN)) {
> -			if (skb_padto(skb, ETH_ZLEN)) {
> -				/* The packet is gone, so we must
> -				 * return 0 */
> -				ss->stats.tx_dropped += 1;
> -				return NETDEV_TX_OK;
> -			}
> -			/* adjust the len to account for the zero pad
> -			 * so that the nic can know how long it is */
> -			skb->len = ETH_ZLEN;
> +		if (eth_skb_pad(skb)) {
> +			/* The packet is gone, so we must
> +			 * return 0 */

    Time to fix the comment style, perhaps? The preferred one for the 
networking code is:

/* bla
  * bla
  */

> +			ss->stats.tx_dropped += 1;

    Hm, why not 'ss->stats.tx_dropped++'?

> +			return NETDEV_TX_OK;
>   		}
>   	}

WBR, Sergei
