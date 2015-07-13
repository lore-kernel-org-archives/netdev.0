From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Mon, 13 Jul 2015 13:04:38 -0700 (PDT)
Message-ID: <20150713.130438.1857789246357119116.davem@davemloft.net>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>
	<20150711.212917.1463596559900301434.davem@davemloft.net>
	<55A415DE.8020806@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, daniel@iogearbox.net, jiri@resnulli.us,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbbGMUEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 16:04:40 -0400
In-Reply-To: <55A415DE.8020806@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 13 Jul 2015 12:47:42 -0700

> In all normal cases skb->users == 1, but pktgen is using trick:
> atomic_add(burst, &skb->users);
> so when testing something like:

You can want pktgen rx (which is the only buggy case as far as I can
see, TX is fine) to run fast, but you must do so by abiding by the
appropriate SKB sharing rules.

You can't do an optimization in pktgen for RX processing that works
"some of the time".  We have shared SKB rules for a reason.

And I don't want to have to explain to someone in the future why that
drop check is there, and have to tell them "because pktgen is broken
and we decided to add a hack here rather than make pktgen send
properly formed SKBs into the RX path"

Ok?
