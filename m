From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Sat, 01 Dec 2012 00:23:35 +0100
Message-ID: <1354317815.11754.498.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
	 <1354230100.3299.40.camel@edumazet-glaptop>
	 <1354269846.11754.381.camel@localhost>
	 <1354287134.3299.67.camel@edumazet-glaptop>
	 <1354290335.11754.447.camel@localhost>
	 <1354293469.3299.81.camel@edumazet-glaptop>
	 <1354311437.11754.459.camel@localhost>
	 <1354314319.20109.179.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22035 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756486Ab2K3X1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 18:27:00 -0500
In-Reply-To: <1354314319.20109.179.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 14:25 -0800, Eric Dumazet wrote:
> On Fri, 2012-11-30 at 22:37 +0100, Jesper Dangaard Brouer wrote:
>
> > Come on Eric, you are smart than this.  When will you realize, that
> > dropping partly completed fragment queue are bad for performance? (And
> > thus a bad algorithmic choice in the evictor)
> 
> Sorry I must be dumb, so I'll stop commenting.

Come on Eric, you are one of the smartest and most enlightened persons I
know.

I'm just a little puzzled (and perhaps annoyed) that you don't agree
that the evictor code is a problem, given the tests I have provided and
the discussion we have had.

On this mailing list we challenge and give each other a hard time on the
technical side, as it should be.  This is nothing personal -- I don't
take it personal, I just believe this patch is important and makes a
difference.


I want us to discuss the evictor code as such.  Not trying to come up
with, workarounds avoiding the evictor code.

The dropping choice in the evictor code is not sound.

We are dealing with assembling fragments.  If a single fragment is lost,
the complete fragment is lost.  The evictor code, will kill off one or
several fragments, knowing that this will invalidate the remaining
fragments.  Under high load, the LRU list has no effect, and cannot
guide the drop choice.  The result is dropping on an "even"/fair basis,
which will basically kill all fragments, letting none complete.  Just as
my tests indicate, it severely affects performance with nearly no
throughput as a result.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
