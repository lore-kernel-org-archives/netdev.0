From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Tue, 24 Mar 2009 23:43:54 -0700 (PDT)
Message-ID: <20090324.234354.43714160.davem@davemloft.net>
References: <49C380A6.4000904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbZCYGoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:44:07 -0400
In-Reply-To: <49C380A6.4000904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 20 Mar 2009 12:40:22 +0100

> I believe we can release dst in dev_queue_xmit(), while cpu cache is
> hot, since caller of dev_queue_xmit() had to hold a reference on dst
> right before. This reduce work to be done by softirq handler, and
> decrease cache misses.
> 

This will break various packet schedulers and classifiers.

Heck sch_sfq.c even uses skb->dst as part of it's flow hash
function :-)
