From: Petr Mladek <pmladek@suse.cz>
Subject: Re: [PATCH 04/16] printk: implement support for extended console
 drivers
Date: Tue, 28 Apr 2015 16:24:13 +0200
Message-ID: <20150428142413.GG3979@pathway.suse.cz>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <1429225433-11946-5-git-send-email-tj@kernel.org>
 <20150420154120.GA4589@pathway.suse.cz>
 <20150427210922.GA2152@htj.duckdns.org>
 <20150428094244.GF3979@pathway.suse.cz>
 <20150428141014.GF2152@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kay Sievers <kay@vrfy.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49583 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030499AbbD1OVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 10:21:45 -0400
Content-Disposition: inline
In-Reply-To: <20150428141014.GF2152@htj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 2015-04-28 10:10:14, Tejun Heo wrote:
> Hello, Petr.
> 
> On Tue, Apr 28, 2015 at 11:42:44AM +0200, Petr Mladek wrote:
> > Note that cont buffer is only a memory optimization. You could put
> > every text snippet into the ring buffer and console immediately.
> > You need to set LOG_CONT instead of LOG_NEWLINE flag. This is
> > already used when the line is too long for the cont buffer or
> > when there is printed a message from another cpu in the middle
> > of a continuing message.
> 
> Yeah, hmmm, I wonder whether the right solution here is to bypass cont
> buffer if ext_console is present.  This would use a bit more memory
> and hurt users catting /proc/kmsg but everyone else should be able to
> get the same result and things get a lot simpler on both sending and
> receiving sides.  What do you think?

I would personally give it a try. If it works well, we might
eventually get rid of the cont buffer completely and make
the printk code a bit easier again.

Best Regards,
Petr
