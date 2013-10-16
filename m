From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: "xfrm: Fix the gc threshold value for ipv4" broke my IPSec
 connections
Date: Wed, 16 Oct 2013 13:35:00 +0200
Message-ID: <20131016113500.GA7660@secunet.com>
References: <525DA855.1010905@daper.net>
 <1381870957.2045.73.camel@edumazet-glaptop.roam.corp.google.com>
 <525DBE65.1070707@daper.net>
 <1381877486.2045.78.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Damian Pietras <damianp@daper.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36119 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932406Ab3JPLfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 07:35:04 -0400
Content-Disposition: inline
In-Reply-To: <1381877486.2045.78.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 03:51:26PM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-16 at 00:15 +0200, Damian Pietras wrote:
> > On 15.10.2013 23:02, Eric Dumazet wrote:
> > >> 703fb94ec58e0e8769380c2877a8a34aeb5b6c97
> > >> xfrm: Fix the gc threshold value for ipv4
> > >>
> > >> Reverting it on 3.10.15 fixes my issue. This seems to be there from 3.7
> > >> and I don't really believe such simple case stayed broken for so long.
> > >> Em I missing something or there is really a bug?
> > >>
> > >> If smeone is interested in details of this configuration and commands
> > >> I'm running, just let me know. This was reproduced with few VMs under XEN.
> > >>
> > > 
> > > It looks like you need to tune /proc/sys/net/ipv4/xfrm4_gc_thresh to a
> > > sensible value given your workload.
> > > 
> > > try :
> > > 
> > > echo 65536 >/proc/sys/net/ipv4/xfrm4_gc_thresh
> > > 
> > > Presumably the 1024 default is really too small...
> > 
> > Now it's working in my test setup, I'm changing it on the production
> > boxes, thanks!
> > 
> > 
> 
> Steffen, what do you think ?
> 
> 1024 seems really small, given we had much higher values.

Sure, we can increase the default value, maybe along with the ipv6 side.
Any recomendation on a good default for both?

> 
> (256 K on a 1GB host)
> 
> This sysctl also needs an entry in
> Documentation/networking/ip-sysctl.txt
> 

Yes, it's undocumented. I'll take care of it.
