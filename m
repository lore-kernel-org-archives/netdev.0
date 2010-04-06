From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] mac80211: Ensure initializing private mc_list in
 prepare_multicast().
Date: Tue, 6 Apr 2010 09:09:23 +0200
Message-ID: <20100406070922.GE2869@psychotron.redhat.com>
References: <201004050457.o354v6ec008492@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755661Ab0DFHJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 03:09:34 -0400
Content-Disposition: inline
In-Reply-To: <201004050457.o354v6ec008492@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 05, 2010 at 05:59:30AM CEST, yoshfuji@linux-ipv6.org wrote:
>Fix kernel panic by NULL pointer dereference in the context of
>ieee80211_ops->prepare_multicast().
>
>This bug was introduced by commit 22bedad3c.. ("net: convert
>multicast list to list_head").
>
>Call __hw_addr_init() in ieee80211_alloc_hw() to initialize
>list_head of private device multicast list, like we do in
>bond_init().
>
>Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>---
> net/mac80211/main.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>
>diff --git a/net/mac80211/main.c b/net/mac80211/main.c
>index 84ad249..0b82cd2 100644
>--- a/net/mac80211/main.c
>+++ b/net/mac80211/main.c
>@@ -388,6 +388,9 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
> 	local->uapsd_max_sp_len = IEEE80211_DEFAULT_MAX_SP_LEN;
> 
> 	INIT_LIST_HEAD(&local->interfaces);
>+
>+	__hw_addr_init(&local->mc_list);
>+
> 	mutex_init(&local->iflist_mtx);
> 	mutex_init(&local->scan_mtx);
> 

Whoups, missed this bit. Thanks a lot.

Rewieved-by: Jiri Pirko <jpirko@redhat.com>

>-- 
>1.5.6.5
>
