From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Wed, 16 Nov 2011 23:03:50 -0800 (PST)
Message-ID: <0a41dc06-15ab-4cf6-9bbd-3a1556993854@tahiti.vyatta.com>
References: <20111117064826.GA4429@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	nic swsd <nic_swsd@realtek.com>,
	eric dumazet <eric.dumazet@gmail.com>
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59929 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709Ab1KQHDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 02:03:51 -0500
In-Reply-To: <20111117064826.GA4429@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Switch to use ndo_get_stats64 to get 64bit statistics.
> Per cpu data is used to avoid lock operations.
> 
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>

This was recently brought up in the proposed forcedeth patch.
You dont need per-cpu since Tx is locked by dev->xmit_lock and
rx is implicitly single threaded by NAPI. You do need to have
two u64_stat_sync entries (one for Tx and one for Rx).  
