From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] enic: fix issues in enic_poll
Date: Thu, 02 Jul 2015 12:10:42 -0700 (PDT)
Message-ID: <20150702.121042.1781111797127542915.davem@davemloft.net>
References: <1435740717-12325-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbbGBTKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 15:10:46 -0400
In-Reply-To: <1435740717-12325-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed,  1 Jul 2015 14:21:57 +0530

> In enic_poll, we clean tx and rx queues, when low latency busy socket polling
> is happening, enic_poll will only clean tx queue. After cleaning tx, it should
> return total budget for re-poll.
> 
> There is a small window between vnic_intr_unmask() and enic_poll_unlock_napi().
> In this window if an irq occurs and napi is scheduled on different cpu, it tries
> to acquire enic_poll_lock_napi() and fails. Unlock napi_poll before unmasking
> the interrupt.
> 
> v2:
> Do not change tx wonk done behaviour. Consider only rx work done for completing
> napi.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thanks.
