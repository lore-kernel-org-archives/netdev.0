From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: clear napi_hash state when copying
 channels
Date: Sun, 13 Nov 2016 13:41:55 -0500 (EST)
Message-ID: <20161113.134155.389939007693100035.davem@davemloft.net>
References: <80535661-f88f-3dc5-9b40-111358707ffd@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45234 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932803AbcKMSl4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 13:41:56 -0500
In-Reply-To: <80535661-f88f-3dc5-9b40-111358707ffd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Fri, 11 Nov 2016 15:56:51 +0000

> efx_copy_channel() doesn't correctly clear the napi_hash related state.
> This means that when napi_hash_add is called for that channel nothing is
> done, and we are left with a copy of the napi_hash_node from the old
> channel. When we later call napi_hash_del() on this channel we have a
> stale napi_hash_node.
> 
> Corruption is only seen when there are multiple entries in one of the
> napi_hash lists. This is made more likely by having a very large number
> of channels. Testing was carried out with 512 channels - 32 channels on
> each of 16 ports.
> 
> This failure typically appears as protection faults within napi_by_id()
> or napi_hash_add(). efx_copy_channel() is only used when tx or rx ring
> sizes are changed (ethtool -G).
> 
> Fixes: 36763266bbe8 ("sfc: Add support for busy polling")
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied to net.
