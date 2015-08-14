From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: fix potential deadlock in
 reqsk_queue_unlink()
Date: Thu, 13 Aug 2015 22:46:56 -0700 (PDT)
Message-ID: <20150813.224656.1301787236393401214.davem@davemloft.net>
References: <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbHNFq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 01:46:56 -0400
In-Reply-To: <1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Aug 2015 15:44:51 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When replacing del_timer() with del_timer_sync(), I introduced
> a deadlock condition :
> 
> reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()
> 
> inet_csk_reqsk_queue_drop() can be called from many contexts,
> one being the timer handler itself (reqsk_timer_handler()).
> 
> In this case, del_timer_sync() loops forever.
> 
> Simple fix is to test if timer is pending.
> 
> Fixes: 2235f2ac75fd ("inet: fix races with reqsk timers")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
