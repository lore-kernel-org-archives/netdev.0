From: Dave Jones <davej@redhat.com>
Subject: Re: order 7 allocations from xt_recent
Date: Thu, 3 Jan 2013 12:26:36 -0500
Message-ID: <20130103172636.GB20982@redhat.com>
References: <20130103164315.GA18908@redhat.com>
 <1357232104.21409.25175.camel@edumazet-glaptop>
 <20130103171115.GA20982@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, h.reindl@thelounge.net,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39739 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430Ab3ACR0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 12:26:45 -0500
Content-Disposition: inline
In-Reply-To: <20130103171115.GA20982@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2013 at 12:11:15PM -0500, Dave Jones wrote:
 > On Thu, Jan 03, 2013 at 08:55:04AM -0800, Eric Dumazet wrote:
 >  > On Thu, 2013-01-03 at 11:43 -0500, Dave Jones wrote:
 >  > > We had a report from a user that shows this code trying
 >  > > to do enormous allocations, which isn't going to work too well..
 >  > >  ...
 >  > > Which is initialised thus..
 >  > > 
 >  > >         ip_list_hash_size = 1 << fls(ip_list_tot);
 >  > > 
 >  > > And ip_list_tot is 10000 in this case. Hmm ?
 >  > > 
 >  > > Complete report and setup described in his bug report at https://bugzilla.redhat.com/show_bug.cgi?id=890715
 >  > 
 >  > Yes, we had a report and a patch :
 >  > 
 >  > http://comments.gmane.org/gmane.linux.network/248216
 >  > 
 >  > I'll send it in a more formal way.
 > 
 > Ah! Excellent.
 > 
 > That 'check size and vmalloc/kmalloc accordingly' thing seems to be a pattern
 > that comes up time and time again.  Is it worth maybe making a more generic
 > version of that instead of open-coding it each time it comes up ?

Something else that I'm puzzled by.

In the report above, it failed to allocate 512kb, but..

Node 0 Normal: 2388*4kB 347*8kB 1029*16kB 3512*32kB 29*64kB 2*128kB 1*256kB 5*512kB 1*1024kB 0*2048kB 0*4096kB = 147128kB
                                                                            ^^^^^^^^^^^^^^^^

Shouldn't the allocator have been able to satisfy that anyway ?

	Dave
