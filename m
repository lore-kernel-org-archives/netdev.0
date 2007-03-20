From: jamal <hadi@cyberus.ca>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 05:25:39 -0400
Message-ID: <1174382739.4864.11.camel@localhost>
References: <45FEEE35.6090606@reflexsecurity.com>
	 <20070319.192206.21926062.davem@davemloft.net>
	 <1174373645.4895.15.camel@localhost>  <45FF8602.8040108@trash.net>
	 <1174375109.4895.22.camel@localhost>  <45FF8D6A.4010308@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris@reflexsecurity.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:49233 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932470AbXCTJZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 05:25:44 -0400
Received: by an-out-0708.google.com with SMTP id b33so1702083ana
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 02:25:44 -0700 (PDT)
In-Reply-To: <45FF8D6A.4010308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-20-03 at 08:29 +0100, Patrick McHardy wrote:
> jamal wrote:
> > On Tue, 2007-20-03 at 07:58 +0100, Patrick McHardy wrote:
> > 
> > Ok. It certainly used to matter in the old days.
> 
> 
> Actually it has never been used anywhere else but in ing_filter,
> it was introduced together with the TC actions.
> 

You are correct. I looked at old 2.4 and all i saw was:

----------
/* 
 revisit later: Use a private since lock dev->queue_lock is also
 used on the egress (might slow things for an iota)
*/
 
         if (dev->qdisc_ingress) {
                 spin_lock(&dev->queue_lock);
                 if ((q = dev->qdisc_ingress) != NULL)
                         fwres = q->enqueue(skb, q);
                 spin_unlock(&dev->queue_lock);
         }
------

So the resolution (as Dave points out) was wrong. In any case, restoring
queue_lock for now would slow things but will remove the race.

> 
> I'll try, but no promises, I'm a bit behind with various things myself.

I will ping you in a few days and if you havent done anything i will
take it up.
I am almost tempted to make the ingress filters to not have any
dependencies on egress whatsoever. It will create more locks but
will make the datapath faster. Actions can still be shared, but thats
lesser of an overhead.

cheers,
jamal

