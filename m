From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: ratelimit failed speed/duplex update
 warning
Date: Sun, 13 Aug 2017 20:02:32 -0700 (PDT)
Message-ID: <20170813.200232.764028072693443116.davem@davemloft.net>
References: <20170811223655.11446-1-futur.andy@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: futur.andy@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdHNDCd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 23:02:33 -0400
In-Reply-To: <20170811223655.11446-1-futur.andy@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Born <futur.andy@googlemail.com>
Date: Sat, 12 Aug 2017 00:36:55 +0200

> bond_miimon_commit() handles the UP transition for each slave of a bond
> in the case of MII. It is triggered 10 times per second for the default
> MII Polling interval of 100ms. For device drivers that do not implement
> __ethtool_get_link_ksettings() the call to bond_update_speed_duplex()
> fails persistently while the MII status could remain UP. That is, in
> this and other cases where the speed/duplex update keeps failing over a
> longer period of time while the MII state is UP, a warning is printed
> every MII polling interval.
> 
> To address these excessive warnings net_ratelimit() should be used.
> Printing a warning once would not be sufficient since the call to
> bond_update_speed_duplex() could recover to succeed and fail again
> later. In that case there would be no new indication what went wrong.
> 
> Fixes: b5bf0f5b16b9c (bonding: correctly update link status during mii-commit phase)
> Signed-off-by: Andreas Born <futur.andy@googlemail.com>
> ---
> Changes in v2:
> * swapped pr_warn_ratelimited() for net_ratelimit()

Applied and you'll be happy to know I queued this up for -stable too :)
