From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: should drop incoming frames without ACK flag set
Date: Wed, 26 Dec 2012 15:09:17 -0800 (PST)
Message-ID: <20121226.150917.847023967466840760.davem@davemloft.net>
References: <1356541801.20133.20615.camel@edumazet-glaptop>
	<20121226.141154.115080358245263295.davem@davemloft.net>
	<1356561874.20133.21098.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhiyunq@umich.edu, nanditad@google.com,
	ncardwell@google.com, john.dykstra1@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193Ab2LZXJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:09:18 -0500
In-Reply-To: <1356561874.20133.21098.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Dec 2012 14:44:34 -0800

> [PATCH v2] tcp: should drop incoming frames without ACK flag set
> 
> In commit 96e0bf4b5193d (tcp: Discard segments that ack data not yet
> sent) John Dykstra enforced a check against ack sequences.
> 
> In commit 354e4aa391ed5 (tcp: RFC 5961 5.2 Blind Data Injection Attack
> Mitigation) I added more safety tests.
> 
> But we missed fact that these tests are not performed if ACK bit is
> not set.
> 
> RFC 793 3.9 mandates TCP should drop a frame without ACK flag set.
> 
> " fifth check the ACK field,
>       if the ACK bit is off drop the segment and return"
> 
> Not doing so permits an attacker to only guess an acceptable sequence
> number, evading stronger checks.
> 
> Many thanks to Zhiyun Qian for bringing this issue to our attention.
> 
> See :
> http://web.eecs.umich.edu/~zhiyunq/pub/ccs12_TCP_sequence_number_inference.pdf
> 
> Reported-by: Zhiyun Qian <zhiyunq@umich.edu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
