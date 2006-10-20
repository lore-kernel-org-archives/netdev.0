From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 14:08:59 -0700 (PDT)
Message-ID: <20061020.140859.95896187.davem@davemloft.net>
References: <20061020.134209.85688168.davem@davemloft.net>
	<20061020134826.75dd1cba@freekitty>
	<200610202301.29859.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11969
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423232AbWJTVI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 17:08:58 -0400
To: ak@suse.de
In-Reply-To: <200610202301.29859.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Fri, 20 Oct 2006 23:01:29 +0200

> netpoll always played a little fast'n'lose with various locking rules.

The current code is fine, it never reenters ->poll, because it
maintains a "->poll_owner" which it checks in netpoll_send_skb()
before trying to call back into ->poll.

Every call to ->poll first sets ->poll_owner to the current cpu id.
netpoll_send_skb() aborts and does a drop if ->poll_owner is set to
the current smp_processor_id().

I sometimes feel like I'm the only person actually reading the sources
and past threads on this topic before replying.
