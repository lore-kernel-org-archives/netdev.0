From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sun, 03 Aug 2008 02:56:16 -0700 (PDT)
Message-ID: <20080803.025616.218557268.davem@davemloft.net>
References: <20080802.121815.167998262.davem@davemloft.net>
	<20080802201944.GA14983@ami.dom.local>
	<20080803092926.GA2971@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58800
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753078AbYHCJ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 05:56:16 -0400
In-Reply-To: <20080803092926.GA2971@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 3 Aug 2008 11:29:26 +0200

> After some re-checking one more question: why do you think this
> qdisc_root_lock() is safe as sch_tree_lock() (or anywhere else)? It
> seems, eg. during deactivation it can get root_lock of qdisc_default,
> and proceed with another qdisc?

We hold RTNL at the time.

If it's the default qdisc, that's fine, we'll reset it and free
up the packets when the RCU handler of the qdisc_destroy() runs.

That's a case where locking the wrong qdisc is OK.
