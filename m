From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac80211: fix locking in
 update_vlan_tailroom_need_count()
Date: Sun, 21 Jun 2015 10:09:41 -0700 (PDT)
Message-ID: <20150621.100941.461361514395666445.davem@davemloft.net>
References: <1434542094-14247-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	michal.kazior@tieto.com, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756052AbbFUQ5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:57:55 -0400
In-Reply-To: <1434542094-14247-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 17 Jun 2015 13:54:54 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Unfortunately, Michal's change to fix AP_VLAN crypto tailroom
> caused a locking issue that was reported by lockdep, but only
> in a few cases - the issue was a classic ABBA deadlock caused
> by taking the mtx after the key_mtx, where normally they're
> taken the other way around.
> 
> As the key mutex protects the field in question (I'm adding a
> few annotations to make that clear) only the iteration needs
> to be protected, but we can also iterate the interface list
> with just RCU protection while holding the key mutex.
> 
> Fixes: f9dca80b98ca ("mac80211: fix AP_VLAN crypto tailroom calculation")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
> Dave, if you're planning to send any more patches to Linus before
> the release, please apply this one. Otherwise let me know and I'll
> sort it out with Cc stable after the merge window.

Applied.
