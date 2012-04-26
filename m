From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] drop_monitor: Make updating data->skb smp safe
Date: Thu, 26 Apr 2012 21:25:36 +0200
Message-ID: <1335468336.2775.62.camel@edumazet-glaptop>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
	 <1335466022-32661-3-git-send-email-nhorman@tuxdriver.com>
	 <1335466809.2775.59.camel@edumazet-glaptop>
	 <20120426191849.GA26072@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47093 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab2DZTZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 15:25:41 -0400
Received: by wgbdr13 with SMTP id dr13so1552623wgb.1
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 12:25:40 -0700 (PDT)
In-Reply-To: <20120426191849.GA26072@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 15:18 -0400, Neil Horman wrote:
> On Thu, Apr 26, 2012 at 09:00:09PM +0200, Eric Dumazet wrote:

> > >  	 * Grab the skb we're about to send
> > >  	 */
> > > -	skb = data->skb;
> > > +	rcu_read_lock();
> > > +	skb = rcu_dereference(data->skb);
> > 
> > This protects nothing ...
> > 
> Hmm, it doesn't really need to be protected either, I just added the read_lock
> to prevent any rcu_dereference from complaining about not holding the
> rcu_read_lock, but as I'm typing this, it occurs to me that that would make
> rcu_dereference_protected the call to use here.  Thanks for kick starting me on
> that.

perfect ;)
