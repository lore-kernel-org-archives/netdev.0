From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 15:46:52 +0200
Message-ID: <1342100812.3265.8260.camel@edumazet-glaptop>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	 <1340945457.29822.7.camel@edumazet-glaptop>
	 <1341396687.2583.1757.camel@edumazet-glaptop>
	 <20120709.000834.1182150057463599677.davem@davemloft.net>
	 <1341845722.3265.3065.camel@edumazet-glaptop>
	 <1341933215.3265.5476.camel@edumazet-glaptop>
	 <CABrhC0=Ls7G-noW1cjsyiF+G5v9f9R=bi6JvrOoT5ZDQB=gSXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ycheng@google.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, therbert@google.com,
	mattmathis@google.com, nanditad@google.com, ncardwell@google.com,
	andrewmcgr@gmail.com
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62302 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480Ab2GLNq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 09:46:58 -0400
Received: by bkwj10 with SMTP id j10so2147787bkw.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 06:46:56 -0700 (PDT)
In-Reply-To: <CABrhC0=Ls7G-noW1cjsyiF+G5v9f9R=bi6JvrOoT5ZDQB=gSXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 09:33 -0400, John Heffner wrote:
> One general question: why a per-connection limit?  I haven't been
> following the bufferbloat conversation closely so I may have missed
> some of the conversation.  But it seems that multiple connections will
> still cause longer queue times.

We already have a per-device limit, in qdisc.

If you want to monitor several tcp sessions, I urge you use a controller
for that. Like codel or fq_codel.

Experiments show that limiting to two TSO packets in qdisc per tcp flow
is enough to stop insane qdisc queueing, without impact on throughput
for people wanting fast tcp sessions.

Thats not solving the more general problem of having 1000 competing
flows.
