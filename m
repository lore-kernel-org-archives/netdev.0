From: Ryousei Takano <takano-ryousei@aist.go.jp>
Subject: Re: [PATCHv2 1/3] NET_SCHED: PSPacer qdisc module
Date: Wed, 28 Nov 2007 01:57:04 +0900 (JST)
Message-ID: <20071128.015704.113039455.takano@axe-inc.co.jp>
References: <474B0D5D.2090506@trash.net>
	<20071127.200803.24564635.takano@axe-inc.co.jp>
	<474C0AA2.5040900@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	dada1@cosmosbay.com, t.kudoh@aist.go.jp
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:59815 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756960AbXK0Q5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 11:57:13 -0500
In-Reply-To: <474C0AA2.5040900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> One more thing: your qdisc can only be used as root qdisc since it
> produces packets itself and thereby violates the rule that a qdisc
> can only hand out packets that were previously enqueued to it.
> Using it as a leaf qdisc can make the upper qdiscs qlen counter
> go negative, causing infinite dequeue-loops, so you should make
> sure that its only possibly to use as root qdisc by checking the
> parent. It would also be better to do something like netem
> (enqueue produced packets at the root) to make sure the qlen
> counter is always accurate.
> 
I agree with you.
PSPacer should not use with other rate regulation qdiscs. But, 
I think that a combination of netem and PSPacer is a useful for
emulating networks. The following paper describes experimental
results using PSPacer with netem:

       "Large Scale Gigabit Emulated Testbed for Grid Transport
       Evaluation", PFLDnet 2006.
       http://www.hpcc.jp/pfldnet2006/paper/s1_02.pdf

Best regards,
Ryousei Takano
