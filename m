From: David Miller <davem@davemloft.net>
Subject: Re: TSO not 10G friendly if peer is close enough
Date: Tue, 17 Apr 2012 17:47:59 -0400 (EDT)
Message-ID: <20120417.174759.327568768780440362.davem@davemloft.net>
References: <4F8D93E1.9090000@intel.com>
	<1334681204.2472.41.camel@edumazet-glaptop>
	<1334698722.2472.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	john.r.fastabend@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab2DQVsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 17:48:08 -0400
In-Reply-To: <1334698722.2472.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Apr 2012 23:38:42 +0200

> Hmm... maybe tcp_trim_head should not trim but only update an offset in
> skb... With some luck, offset can reach skb->len when all data is
> ACKnowledged...

This is definitely the way to fix this.  Just essentially defer all
the page operations until later when the entire SKB is consumed.
