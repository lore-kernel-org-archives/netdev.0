From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 11 Aug 2008 18:12:35 -0700 (PDT)
Message-ID: <20080811.181235.141399855.davem@davemloft.net>
References: <20080811205357.GA15293@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750722AbYHLBMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:12:35 -0400
In-Reply-To: <20080811205357.GA15293@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 11 Aug 2008 22:53:57 +0200

> pkt_sched: Destroy gen estimators under rtnl_lock().
> 
> gen_kill_estimator() requires rtnl_lock() protection, and since it is
> called in qdisc ->destroy() too, this has to go back from RCU callback
> to qdisc_destroy().
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

We can't do this.  And at a minimum, the final ->reset() must
occur in the RCU callback, otherwise asynchronous threads of
execution could queue packets into this dying qdisc and
such packets would leak forever.
