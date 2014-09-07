From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 2/3] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Sun, 7 Sep 2014 23:50:39 +0200
Message-ID: <20140907215039.GA3900@localhost.localdomain>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
 <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57733 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbaIGVuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 17:50:46 -0400
Received: by mail-wi0-f178.google.com with SMTP id n3so1564454wiv.5
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 14:50:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just saw this now, was away on vacation, so sorry for the delay...

On Thu, Sep 04, 2014 at 01:31:35PM -0400, Alexander Duyck wrote:
> v2: Renamed function to skb_clone_sk.
>     Added destructor to call sock_put instead of doing it ourselves.
>     Dropped freeing functionality from skb_complete_tx_timestamp.

...

> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
> index d5991ac..87648b3 100644
> --- a/drivers/net/phy/dp83640.c
> +++ b/drivers/net/phy/dp83640.c
> @@ -1148,7 +1148,7 @@ static void dp83640_remove(struct phy_device *phydev)
>  		kfree_skb(skb);
>  
>  	while ((skb = skb_dequeue(&dp83640->tx_queue)) != NULL)
> -		skb_complete_tx_timestamp(skb, NULL);
> +		kfree_skb(skb);

The way the code was before, there was a clear usage pattern for
phy_driver.txtstamp() and skb_complete_tx_timestamp() which was also
documented in the comment to the latter.

Now, we have drivers freeing buffers allocated by the stack.  I
thought it was cleaner to have the same layer allocate and free the
clone. Even if you say that this new way is just fine, still you
should correct the comment to reflect the new pattern.

Thanks,
Richard
