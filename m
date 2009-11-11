From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 14:24:22 -0800
Message-ID: <20091111142422.0b6d22fa@nehalam>
References: <200911112116.14103.opurdila@ixiacom.com>
	<20091111.124235.243348591.davem@davemloft.net>
	<20091111133342.1011e16a@nehalam>
	<200911112347.41425.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42764 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759315AbZKKWYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 17:24:42 -0500
In-Reply-To: <200911112347.41425.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Nov 2009 23:47:41 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> On Wednesday 11 November 2009 23:33:42 you wrote:
> > On Wed, 11 Nov 2009 12:42:35 -0800 (PST)
> > 
> > David Miller <davem@davemloft.net> wrote:
> > > From: Octavian Purdila <opurdila@ixiacom.com>
> > > Date: Wed, 11 Nov 2009 21:38:44 +0200
> > >
> > > > I don't think we can dynamically size it at boot time since it
> > > > depends on the usage pattern which is impossible to determine at
> > > > boot time, right?
> > >
> > > We have no idea how many sockets will be used by the system yet we
> > > dynamically size the socket hash tables.
> > >
> > > Please do some research and see how we handle this elsewhere in the
> > > networking.
> > 
> > dcache also sizes hash bits at boot time on available memory.
> > See alloc_large_system_hash().
> > 
> 
> Thanks Stephen.
> 
> I was actually taking a look at that but I see that the device hash is 
> allocated per net namespace which means we can't use 
> alloc_large_system_hash().
> 
> We could use a similar function that will work in the per namespace 
> initialization context, but this might upset net namespace folks since we will 
> get a large hash for every namespace.
> 
> Not sure what can be done to address that problem now except using a boot 
> parameter to override the defaults. A better solution would be to be able to 
> use "namespace create" parameters but it appears we don't have this 
> possibility, yet.
> 

Remember though that really hash sizes really don't buy that much more speed.
Going from 256 to 1024 gives a 4x benefit but with 10,000 devices that
just means scanning 10 vs. 40 names. It is not like the file system cache
where name lookup is a major component of overhead.

You can still use alloc_large_system_hash, but just constrain it to a maximum
of order 10 or something.

-- 
