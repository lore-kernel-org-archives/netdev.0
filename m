From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 23:47:41 +0200
Message-ID: <200911112347.41425.opurdila@ixiacom.com>
References: <200911112116.14103.opurdila@ixiacom.com> <20091111.124235.243348591.davem@davemloft.net> <20091111133342.1011e16a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:28506 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759367AbZKKVuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 16:50:40 -0500
In-Reply-To: <20091111133342.1011e16a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 11 November 2009 23:33:42 you wrote:
> On Wed, 11 Nov 2009 12:42:35 -0800 (PST)
> 
> David Miller <davem@davemloft.net> wrote:
> > From: Octavian Purdila <opurdila@ixiacom.com>
> > Date: Wed, 11 Nov 2009 21:38:44 +0200
> >
> > > I don't think we can dynamically size it at boot time since it
> > > depends on the usage pattern which is impossible to determine at
> > > boot time, right?
> >
> > We have no idea how many sockets will be used by the system yet we
> > dynamically size the socket hash tables.
> >
> > Please do some research and see how we handle this elsewhere in the
> > networking.
> 
> dcache also sizes hash bits at boot time on available memory.
> See alloc_large_system_hash().
> 

Thanks Stephen.

I was actually taking a look at that but I see that the device hash is 
allocated per net namespace which means we can't use 
alloc_large_system_hash().

We could use a similar function that will work in the per namespace 
initialization context, but this might upset net namespace folks since we will 
get a large hash for every namespace.

Not sure what can be done to address that problem now except using a boot 
parameter to override the defaults. A better solution would be to be able to 
use "namespace create" parameters but it appears we don't have this 
possibility, yet.

