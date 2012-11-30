From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 15:58:57 -0800
Message-ID: <1354319937.20109.285.camel@edumazet-glaptop>
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
	 <1354317815.11754.498.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:54623 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533Ab2K3X7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 18:59:02 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so686847pad.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 15:59:01 -0800 (PST)
In-Reply-To: <1354317815.11754.498.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-01 at 00:23 +0100, Jesper Dangaard Brouer wrote:


> I'm just a little puzzled (and perhaps annoyed) that you don't agree
> that the evictor code is a problem, given the tests I have provided and
> the discussion we have had.
> 
> On this mailing list we challenge and give each other a hard time on the
> technical side, as it should be.  This is nothing personal -- I don't
> take it personal, I just believe this patch is important and makes a
> difference.
> 
> 
> I want us to discuss the evictor code as such.  Not trying to come up
> with, workarounds avoiding the evictor code.
> 
> The dropping choice in the evictor code is not sound.
> 
> We are dealing with assembling fragments.  If a single fragment is lost,
> the complete fragment is lost.  The evictor code, will kill off one or
> several fragments, knowing that this will invalidate the remaining
> fragments.  Under high load, the LRU list has no effect, and cannot
> guide the drop choice.  The result is dropping on an "even"/fair basis,
> which will basically kill all fragments, letting none complete.  Just as
> my tests indicate, it severely affects performance with nearly no
> throughput as a result.

Give me an alternative, I'll tell you how an attacker can hurt you,
knowing the strategy you use.

Keeping around old frags is not good. After a burst of frags, you'll be
unable to recover until they are purged.

Purging old frags is the most natural way to evict incomplete messages.

(If your mem limits are high enough to absorb the expected workload plus
a fair amount of extra space, but your results are biased with wrong
thresholds)

Or else, an attacker only has to send incomplete messages, and your host
will fill its table and refuse your messages.
