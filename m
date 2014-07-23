From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v8 5/6] openvswitch: Sample action without
 side effects
Date: Wed, 23 Jul 2014 14:47:59 -0700 (PDT)
Message-ID: <20140723.144759.1498389231853548910.davem@davemloft.net>
References: <1406054116-1758-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933516AbaGWVsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:48:00 -0400
In-Reply-To: <1406054116-1758-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 22 Jul 2014 11:35:16 -0700

> * As sample() provides a cloned skb in the unlikely case where there are
>   nested actions other than a single userspace action it is no longer
>   necessary to clone the skb in do_execute_actions() when executing a
>   recirculation action just because the keep_skb parameter is set:

This commit log message talks about recirculation, which has been removed
from this series.

And in fact, I think, for my suggested implementation of recirculation
by just returning and re-running the stack, this whole skb clone issue
either goes away or needs to happen in a different place.

If you recirculate by just returning and re-processing the packet at
the top-level entry point into openvswitch, then that's where you
would clone.
