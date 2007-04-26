From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] export SAD info
Date: Thu, 26 Apr 2007 09:10:10 -0400
Message-ID: <1177593010.4077.18.camel@localhost>
References: <1177515761.9923.3.camel@localhost>
	 <1177516490.9923.7.camel@localhost>
	 <20070426.001850.55508944.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:42157 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031226AbXDZNKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 09:10:14 -0400
Received: by an-out-0708.google.com with SMTP id b33so216522ana
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 06:10:14 -0700 (PDT)
In-Reply-To: <20070426.001850.55508944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-26-04 at 00:18 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>

> > Would it make sense to have those vars as u32 instead of unsigned int?
> 
> I'm ambivalent, "unsigned int" happens to be 32-bit on every platform.
> So changing it would cause no harm :-)

If unsigned int is always u32 i will leave it as is.

I would have liked to just do a read_lock_bh when retrieving the table
metadata; however, the state table lock is defined as DEFINE_SPINLOCK
unlike the policy table which is defined as DEFINE_RWLOCK.
Any objection to change the state lock to be RW?

BTW, if i can get the SADinfo, then i should be able to set it from user
space too;->
So that would be my next change unless there is objection.

One other angle is start rejecting additions to the table after some
point. To test, I wrote a little DOS tool that just kept adding entries
until an OOM hit. It is a lot of fun to watch when you hit a point that
swap is guzzling 2G or more. The add latency starts going up
exponentially.
I would like to enable the admin to set the proper param settings for
upper bound. Exceeding the upper bounds of the max entries a table
should have returns ENOMEM for any new entries. By default current
behavior is maintained.

Thoughts?

cheers,
jamal

