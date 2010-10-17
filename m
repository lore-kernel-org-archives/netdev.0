From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Sun, 17 Oct 2010 22:36:18 +0200
Message-ID: <20101017203618.GA1889@del.dom.local>
References: <20101014031354.e172d737.billfink@mindspring.com>
 <20101014080939.GA7710@ff.dom.local>
 <20101014085005.GA8349@ff.dom.local>
 <20101015023749.f085006b.billfink@mindspring.com>
 <1287125059.2659.1812.camel@edumazet-laptop>
 <20101015173746.12c7c40a.billfink@mindspring.com>
 <20101015220535.GA1997@del.dom.local>
 <20101016005106.35e4cc8d.billfink@mindspring.com>
 <20101016205824.GA2113@del.dom.local>
 <20101016212434.72ae5250.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40339 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932735Ab0JQUg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Oct 2010 16:36:29 -0400
Received: by wyb28 with SMTP id 28so317740wyb.19
        for <netdev@vger.kernel.org>; Sun, 17 Oct 2010 13:36:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101016212434.72ae5250.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 16, 2010 at 09:24:34PM -0400, Bill Fink wrote:
> On Sat, 16 Oct 2010, Jarek Poplawski wrote:
...
> > http://code.google.com/p/pspacer/wiki/HTBon10GbE
> >  
> > If it doesn't help reconsider hfsc.
> 
> Thanks for the link.  From his results, it appears you can
> get better accuracy by keeping TSO/GSO enabled and upping
> the tc mtu parameter to 64000.  I will have to try that out.

Sure, but you have to remember that scheduler doesn't know real packet
sizes and rate tables are less accurate especially for smaller packets,
so it depends on conditions.

> For the very high bandwidth cases I tend to deal with, would
> there be any advantage to further reducing the PSCHED_SHIFT
> from its current value of 6?

If you don't use low rates and/or large buffers it might be a good
idea, especially on x64 (for 32-bit longs htb needs some change for
this value below 5).

Jarek P.
