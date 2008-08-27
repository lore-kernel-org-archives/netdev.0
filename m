From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 14:48:00 -0700
Message-ID: <20080827144800.5f9fc5b4@extreme>
References: <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com>
	<20080826163719.GA25066@redhat.com>
	<87zlmyr5nz.fsf@basil.nowhere.org>
	<20080827.142941.50104491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54283 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbYH0VsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 17:48:02 -0400
In-Reply-To: <20080827.142941.50104491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008 14:29:41 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andi Kleen <andi@firstfloor.org>
> Date: Wed, 27 Aug 2008 14:41:52 +0200
> 
> > Dave Jones <davej@redhat.com> writes:
> > 
> > > Just had this bug reported against our development tree..
> > 
> > SUSE had an old patch for this which unfortunately got rejected 
> > some time ago for some bogus reason.
> 
> Really, your patch fixes this specific slowdown that got introduced
> recently?  I really doubt it Andi, so please don't use this as an
> opportunity to toot your own horn, thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I do wonder if having large hash table actually helps? When TCP hash
table gets too big, it means every lookup is a cache miss. Assuming
a busy server with 2000 connections and perfect hash. On a 4G mem x86-64
we are doing 512K hash entries which is ridiculous. Something like 64K
entries is more than enough.
