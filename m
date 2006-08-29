From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Tue, 29 Aug 2006 13:17:44 -0700
Message-ID: <20060829131744.43a018b0@localhost.localdomain>
References: <20060828230748.827712918@localhost.localdomain>
	<20060828230915.587544687@localhost.localdomain>
	<20060829152816.GA24283@ms2.inr.ac.ru>
	<20060829112204.0cf5e866@localhost.localdomain>
	<1156876442.25085.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40908 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965056AbWH2USX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:18:23 -0400
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1156876442.25085.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006 20:34:01 +0200
Martin Josefsson <gandalf@wlug.westbo.se> wrote:

> On Tue, 2006-08-29 at 11:22 -0700, Stephen Hemminger wrote:
> 
> > > Probably, you should do atomic_inc_and_test() here and restart lookup,
> > > if it fails.
> > > 
> > > Alexey
> > 
> > atomic_inc_and_test is true iff result is zero, so that won't work.
> 
> Wouldn't atomic_inc_not_zero() do what you want?
> 

Yes, but that code looks more complex for the common case.
It ends up doing a compare exchange and retrying.

-- 
Stephen Hemminger <shemminger@osdl.org>
