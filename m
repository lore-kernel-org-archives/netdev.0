From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: consolidate tc_classify{,_compat}
Date: Thu, 27 Aug 2015 14:19:39 -0700 (PDT)
Message-ID: <20150827.141939.681226506664674587.davem@davemloft.net>
References: <3dfe133299d033dfa52bcf63d846f3f91b56d30c.1440620622.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbbH0VTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:19:40 -0400
In-Reply-To: <3dfe133299d033dfa52bcf63d846f3f91b56d30c.1440620622.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 26 Aug 2015 23:00:06 +0200

> For classifiers getting invoked via tc_classify(), we always need an
> extra function call into tc_classify_compat(), as both are being
> exported as symbols and tc_classify() itself doesn't do much except
> handling of reclassifications when tp->classify() returned with
> TC_ACT_RECLASSIFY.
> 
> CBQ and ATM are the only qdiscs that directly call into tc_classify_compat(),
> all others use tc_classify(). When tc actions are being configured
> out in the kernel, tc_classify() effectively does nothing besides
> delegating.
> 
> We could spare this layer and consolidate both functions. pktgen on
> single CPU constantly pushing skbs directly into the netif_receive_skb()
> path with a dummy classifier on ingress qdisc attached, improves
> slightly from 22.3Mpps to 23.1Mpps.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
