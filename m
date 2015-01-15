From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Thu, 15 Jan 2015 15:58:33 +0100
Message-ID: <8088599.PZmG8U31O2@storm>
References: <1719052.SGOfRAJhfQ@storm> <5229621.KczjbIR22Q@storm> <1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7Bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:58366 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbbAOO6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 09:58:37 -0500
In-Reply-To: <1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 15. January 2015 06:43:29 Eric Dumazet wrote:
> > -#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
> > +#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(4096)
> > 
> >  #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE <<
> >  NETDEV_FRAG_PAGE_MAX_ORDER) #define NETDEV_PAGECNT_MAX_BIAS          
> >  NETDEV_FRAG_PAGE_MAX_SIZE> 
> > When I try a page size of 8192, it starts failing again. I'll now run
> > a stress test with 4096 to see if the problem is really gone
> > or just happens more rarely.
> 
> Sure, you basically reverted my patch.
> 
> You are not the first to report a problem caused by this patch.
> 
> This patch is known to have uncovered some driver bugs.
> 
> We are not going to revert it. We are going to fix the real bugs.
> 
> Thanks

A colleague mentioned to me he saw the "Hardware Unit Hang" message every 
few days even running on kernel 3.4 (without your patch). Basically I'm 
testing now if that's still the case with 3.19-rc4+ or not.

I'm all for fixing the root cause. I'm just interested if the e1000e
hang can even be triggered when using a max frag page size of 4096.
So far it transferred 751.6 GiB without a hiccup.

Cheers,
Thomas
