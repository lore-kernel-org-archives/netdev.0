From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix lockdep warning on est_tree_lock in
 gen_estimator
Date: Thu, 02 Sep 2010 13:22:48 -0700 (PDT)
Message-ID: <20100902.132248.229742285.davem@davemloft.net>
References: <20100902201257.GA3089@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751217Ab0IBUWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:22:32 -0400
In-Reply-To: <20100902201257.GA3089@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 2 Sep 2010 22:12:58 +0200

> This patch fixes a lockdep warning:
> 
> [  516.287584] =========================================================
> [  516.288386] [ INFO: possible irq lock inversion dependency detected ]
> [  516.288386] 2.6.35b #7
> [  516.288386] ---------------------------------------------------------
> [  516.288386] swapper/0 just changed the state of lock:
> [  516.288386]  (&qdisc_tx_lock){+.-...}, at: [<c12eacda>] est_timer+0x62/0x1b4
> [  516.288386] but this lock took another, SOFTIRQ-unsafe lock in the past:
> [  516.288386]  (est_tree_lock){+.+...}
> [  516.288386] 
> [  516.288386] and interrupts could create inverse lock ordering between them.
> ...
> 
> So, est_tree_lock needs BH protection because it's taken by
> qdisc_tx_lock, which is used both in BH and process contexts.
> (Full warning with this patch at netdev, 02 Sep 2010.)
> 
> Fixes commit: ae638c47dc040b8def16d05dc6acdd527628f231
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.

Eric, please make an effort to run with lockdep enabled when making
locking changes, just for fun :-)
