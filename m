From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] mac80211: fix channel switch for chanctx-based drivers
Date: Mon, 18 Aug 2014 16:40:28 +0300
Message-ID: <1408369228.20137.6.camel@dubbel>
References: <1408351816.29649.8.camel@dubbel>
	 <1408360749-10233-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dedo.coelho.fi ([88.198.205.34]:41858 "EHLO dedo.coelho.fi"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750806AbaHRNkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 09:40:47 -0400
In-Reply-To: <1408360749-10233-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-18 at 13:19 +0200, Michal Kazior wrote:
> The new_ctx pointer is set only for non-chanctx
> drivers. This yielded a crash for chanctx-based
> drivers during channel switch finalization:
> 
>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
>   IP: ieee80211_vif_use_reserved_switch+0x71c/0xb00 [mac80211]
> 
> Use an adequate chanctx pointer to fix this.
> 
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
> ---
> Note: This is based on mac80211-next/master albeit
> it should apply cleanly on wireless-next/master
> and v3.17-rc1.
> 
> I've verified this fix with iwlmvm & 7260.

Cool!  I've also tested this (with P2P client) and it works fine.  You
can add my:

Tested-by: Luciano Coelho <luciano.coelho@intel.com>

The reason I haven't seen this before is because I've been using 2
channels support with iwlmvm, so we never get an in-place channel
switch. :( The normal case is to have single channel support...

--
Cheers,
Luca.
