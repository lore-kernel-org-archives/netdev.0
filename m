From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Fix ageing conditions and
 operation
Date: Tue, 08 Sep 2015 22:28:06 -0700 (PDT)
Message-ID: <20150908.222806.2296252940023685292.davem@davemloft.net>
References: <1441483647-8278-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	linux@roeck-us.net, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbbIIF2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 01:28:10 -0400
In-Reply-To: <1441483647-8278-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  5 Sep 2015 13:07:27 -0700

> The comparison check between cur_hw_state and hw_state is currently
> invalid because cur_hw_state is right shifted by G_MISTP_SHIFT, while
> hw_state is not, so we end-up comparing bits 2:0 with bits 7:5, which is
> going to cause an additional aging to occur. Fix this by not shifting
> cur_hw_state while reading it, but instead, mask the value with the
> appropriately shitfted bitmask.
> 
> The other problem with the fast-ageing process is that we did not set
> the EN_AGE_DYNAMIC bit to request the ageing to occur for dynamically
> learned MAC addresses. Finally, write back 0 to the FAST_AGE_CTRL
> register to avoid leaving spurious bits sets from one operation to the
> other.
> 
> Fixes: 12f460f23423 ("net: dsa: bcm_sf2: add HW bridging support")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> David, this dates back to 4.1, could you queue this for -stable?

Applied and queued up for -stable, thanks!
