From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Wed, 14 Apr 2010 07:58:24 -0400
Message-ID: <1271246304.3943.60.camel@bigi>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:51329 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031Ab0DNL61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 07:58:27 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1939qwh.37
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 04:58:27 -0700 (PDT)
In-Reply-To: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-14 at 17:52 +0800, Changli Gao wrote:
> batch skb dequeueing from softnet input_pkt_queue
> 
> batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
> contention and irq disabling/enabling.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

It seems we are now going to generate a lot more IPIs with such a
change. At least this is what i am imagining.
CPU0: packet comes in,queue empty, generate an IPI to CPU1
CPU0: second packet comes in, enqueue
CPU1: grab two packets to process and run with them
CPU0: packet comes in,queue empty, generate an IPI to CPU1
..
...
.....

IPIs add to latency (refer to my other email). Did you test this
to reach some conclusion that it improves thing or was it just by
inspection?

cheers,
jamal

