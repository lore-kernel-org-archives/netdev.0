From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 11:32:14 -0400
Message-ID: <1309102334.5134.31.camel@mojatatu>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309100994.2532.35.camel@edumazet-laptop>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62773 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074Ab1FZPcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 11:32:16 -0400
Received: by iwn6 with SMTP id 6so3512567iwn.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 08:32:16 -0700 (PDT)
In-Reply-To: <1309100994.2532.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-26 at 17:09 +0200, Eric Dumazet wrote:


> I would just remove the jiffies break, now we have a 64 packets limit...
> 
> if (quota >= work || need_resched()) {
> 	...
> }

Seems reasonable to do. Some stats (on two different machines
at least with dummy) on a system with low # of processes:
~80% of the time - we exit the loop because of packet quota
~1% for both need_resched and jiffy
~19% simply because there were less than quota packets

Note: we do use a jiffy check on net_rx_action() but i suspect
we never ever hit it.

cheers,
jamal

