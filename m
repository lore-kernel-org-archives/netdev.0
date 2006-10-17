From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/14] [TIPC] Fix socket receive queue NULL pointer
 dereference on SMP systems
Date: Mon, 16 Oct 2006 21:55:29 -0700 (PDT)
Message-ID: <20061016.215529.35663904.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<1160739475921-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xpl@amln.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49099
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423058AbWJQEz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:55:28 -0400
To: per.liden@ericsson.com
In-Reply-To: <1160739475921-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:49 +0200

> From: P Litov <xpl@amln.net>
> 
> This patch corrects an SMP system-specific race condition which allowed
> TIPC to prematurely dereference the first sk_buff in a socket receive
> queue that was changing from empty to non-empty state.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

If you are going to access the socket packet without some other kind
of locking that prevents changes to the queue, you must take the skb
queue lock.  You can't dance around it by checking the linked list
pointer instead the queue length.  Otherwise we'd be doing this all
over the UDP code and other datagram socket layers.  And we don't
because it simply isn't valid.

So I'm not applying this.

Also, this patch is missing a proper signed off line from the
patch author, P Litov.
