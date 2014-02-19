From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netfront: reset skb network header before
 checksum
Date: Wed, 19 Feb 2014 16:53:30 -0500 (EST)
Message-ID: <20140219.165330.1494132817520500296.davem@davemloft.net>
References: <1392835714-26480-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	linux@eikelenboom.it, konrad.wilk@oracle.com,
	paul.durrant@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbaBSVxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:53:32 -0500
In-Reply-To: <1392835714-26480-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Wed, 19 Feb 2014 18:48:34 +0000

> In ed1f50c3a ("net: add skb_checksum_setup") we introduced some checksum
> functions in core driver. Subsequent change b5cf66cd1 ("xen-netfront:
> use new skb_checksum_setup function") made use of those functions to
> replace its own implementation.
> 
> However with that change netfront is broken. It sees a lot of checksum
> error. That's because its own implementation of checksum function was a
> bit hacky (dereferencing skb->data directly) while the new function was
> implemented using ip_hdr(). The network header is not reset before skb
> is passed to the new function. When the new function tries to do its
> job, it's confused and reports error.
> 
> The fix is simple, we need to reset network header before passing skb to
> checksum function. Netback is not affected as it already does the right
> thing.
> 
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied, thanks.
