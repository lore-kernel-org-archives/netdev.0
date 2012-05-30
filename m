From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling
 to mitigate SYN floods
Date: Wed, 30 May 2012 10:24:48 +0200
Message-ID: <1338366288.2760.115.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <m2bol6lqxo.fsf@firstfloor.org> <1338360073.2760.81.camel@edumazet-glaptop>
	 <201205301013.10797.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Tom Herbert <therbert@google.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58093 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab2E3IYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 04:24:54 -0400
Received: by bkcji2 with SMTP id ji2so3849216bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 01:24:52 -0700 (PDT)
In-Reply-To: <201205301013.10797.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:03 +0200, Hans Schillstrom wrote:

> We have this option running right now, and it gave slightly higher values.
> The upside is only one core is running at 100% load.
> 
> To be able to process more SYN an attempt was made to spread them with RPS to 
> 2 other cores gave 60% more SYN:s per sec
> i.e. syn filter in NIC sending all irq:s to one core gave ~ 52k syn. pkts/sec
> adding RPS and sending syn to two other core:s gave ~80k  syn. pkts/sec
> Adding more cores than two didn't help that much.

When you say 52.000 pkt/s, is that for fully established sockets, or
SYNFLOOD ?

19.23 us to handle _one_ SYN message seems pretty wrong to me, if there
is no contention on listener socket.
