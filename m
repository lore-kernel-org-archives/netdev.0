From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sun, 24 Aug 2014 12:08:54 -0700 (PDT)
Message-ID: <20140824.120854.1649653834184145660.davem@davemloft.net>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<20140823.213839.1953243016141233125.davem@davemloft.net>
	<53F9FD5C.2090408@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbaHXTIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 15:08:55 -0400
In-Reply-To: <53F9FD5C.2090408@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 24 Aug 2014 10:57:32 -0400

> Clearly, the best thing to do is avoid altogether the need to have
> such a list. The only reason you need a list around is because you
> dont know how much you can send to the driver. tx_win idea may not
> be the best but it tried to address that issue.

I think it is unavoidable for us to have to do a "send and recheck
queue state" approach, because of the issues I brought up the other
day.

Every driver has it's own set of restrictions and how many TX slots
a given SKB can consume in it's TX queue.

So from that perspective a list we perform retries on is an approach
we must consider seriously.
