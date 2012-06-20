From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 02:30:02 -0700 (PDT)
Message-ID: <20120620.023002.243497856926894946.davem@davemloft.net>
References: <20120619.214957.1282277480138040899.davem@davemloft.net>
	<alpine.LFD.2.00.1206200937040.1912@ja.ssi.bg>
	<20120620.005753.545788933895952782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab2FTJaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 05:30:02 -0400
In-Reply-To: <20120620.005753.545788933895952782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 20 Jun 2012 00:57:53 -0700 (PDT)

> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed, 20 Jun 2012 10:00:37 +0300 (EEST)
> 
>> 			if (skb->dev != dst->dev)
>> 				dst = NULL;
> 
> That makes the most sense.

Doesn't work, dst->dev is &net->loopback_dev for these locally
destined input routes.

We have to instead check rt->rt_iif or similar.
