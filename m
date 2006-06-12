From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.17-rc5-mm3-lockdep -
Date: Sun, 11 Jun 2006 23:50:05 -0700 (PDT)
Message-ID: <20060611.235005.51843280.davem@davemloft.net>
References: <4485AFB9.3040005@s5r6.in-berlin.de>
	<20060607071208.GA1951@gondor.apana.org.au>
	<20060612063807.GA23939@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, stefanr@s5r6.in-berlin.de,
	Valdis.Kletnieks@vt.edu, jirislaby@gmail.com, akpm@osdl.org,
	arjan@infradead.org, mingo@redhat.com,
	linux-kernel@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54204
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751055AbWFLGt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 02:49:58 -0400
To: mingo@elte.hu
In-Reply-To: <20060612063807.GA23939@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 12 Jun 2006 08:38:07 +0200

> yeah. I'll investigate - it's quite likely that sk_receive_queue.lock 
> will have to get per-address family locking rules - right?

That's right.

> Maybe it's enough to introduce a separate key for AF_UNIX alone (and 
> still having all other protocols share the locking rules for 
> sk_receive_queue.lock) , by reinitializing its spinlock after 
> sock_init_data()?

AF_NETLINK and/or AF_PACKET might be in a similar situation
as AF_UNIX.
