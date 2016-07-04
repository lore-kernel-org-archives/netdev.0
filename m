From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/1] net sched actions: mirred add support
 for setting Dst MAC address
Date: Mon, 04 Jul 2016 15:14:35 -0700 (PDT)
Message-ID: <20160704.151435.624086916441807197.davem@davemloft.net>
References: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:50412 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752357AbcGDWOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 18:14:36 -0400
In-Reply-To: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sat,  2 Jul 2016 10:34:25 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Often redirecting or mirroring requires that we set the dstMAC address
> of the target device. While it is possible to pipe to a pedit action,
> this patch obsoletes the need for that. This is a justified feature because
> the dst MAC addresses rewrite is such a common use case.
> 
> Sample usage:
> sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action mirred egress redirect dev $SPANPORT dst 02:15:15:15:15:15
> 
> This will match all icmp packets going out on dev $ETH and
> redirect them to dev $SPANPORT while setting their dst MAC address
> to 02:15:15:15:15:15
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

I agree with Jiri.

The whole model is to chain together the actions that you need to
accomplish whatever it is you want to do.

This means actions are as specialized as possible, and do one thing
as precisely and efficiently as possible.

It seems unnecessary to break this model and start to make swiss army
knife actions.

Every time we find some "common use case" will we turn yet another
action into a Frankenstein thing that does more than it was designed
to do?

I don't want to apply this and start us down this road, seriously...
