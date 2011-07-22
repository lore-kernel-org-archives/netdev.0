From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Thu, 21 Jul 2011 17:08:55 -0700 (PDT)
Message-ID: <20110721.170855.1343650615466483577.davem@davemloft.net>
References: <4E28A4C8.8040707@candelatech.com>
	<20110721.151903.297506479006061401.davem@davemloft.net>
	<20110721235049.GA29489@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, eric.dumazet@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, adobriyan@gmail.com,
	robert.olsson@its.uu.se
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab1GVAKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 20:10:07 -0400
In-Reply-To: <20110721235049.GA29489@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 21 Jul 2011 19:50:49 -0400

> I'm happy to go down this route Dave, and agree, its a more solid solution, but
> I think the problem with it (which Ben may have been alluding to previously) is
> that pktgen doesn't use dev_queue_xmit or dev_hard_start_xmit to send frames.

Neil, that's THE WHOLE POINT, and HOW MY IDEA WORKS.

Pktgen bypasses those functions, so it won't trigger the check and
therefore won't trigger making a copy of the SKB, since copying isn't
needed.

Only layering devices will end up eventually calling into those two
functions and trigger the "need to copy because this SKB is pktgen
shared" check.
