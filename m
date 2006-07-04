From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 4 Jul 2006 13:54:22 +0200
Message-ID: <200607041354.22472.ak@suse.de>
References: <4492D5D3.4000303@atmos.washington.edu> <200606260723.43209.ak@suse.de> <Pine.LNX.4.61.0607041333030.18483@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:4830 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932219AbWGDLy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 07:54:29 -0400
To: Jesper Dangaard Brouer <hawk@diku.dk>
In-Reply-To: <Pine.LNX.4.61.0607041333030.18483@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 July 2006 13:41, Jesper Dangaard Brouer wrote:
> 
> On Mon, 26 Jun 2006, Andi Kleen wrote:
> 
> >> I encountered the same problem on a dual core opteron equipped with a
> >> broadcom NIC (tg3) under 2.4. It could receive 1 Mpps when using TSC
> >> as the clock source, but the time jumped back and forth, so I changed
> >> it to 'notsc', then the performance dropped dramatically to around the
> >> same value as above with one CPU saturated. I suspect that the clock
> >> precision is needed by the tg3 driver to correctly decide to switch to
> >> polling mode, but unfortunately, the performance drop rendered the
> >> solution so much unusable that I finally decided to use it only in
> >> uniprocessor with TSC enabled.
> >
> > 2.6 is more clever at this than 2.4. In particular it does the timestamp
> > for each packet only when actually needed, which is relativelt rare.
> >
> > Old experiences do not always apply to new kernels.
> 
> Note, that I experinced this problem on 2.6.
> 
> Actually the change happens between kernel version 2.6.15 and 2.6.16.

The timestamp optimizations are older. Don't remember the exact release,
but earlier 2.6.

> And  
> is a result of Andi's changes to arch/x86_64/Kconfig and 
> drivers/acpi/Kconfig, which "allows/activates" the use of the timer on 
> x86_64.

Not sure what you mean here?

2.6.18 will likely be more aggressive at using the TSC on i386 on
Intel systems where possible, but x86-64 did this already for a long time. 
When x86-64 uses non TSC then it's because using the TSC is not safe.

-Andi
