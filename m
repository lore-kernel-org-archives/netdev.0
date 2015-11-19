From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Thu, 19 Nov 2015 13:58:36 -0800
Message-ID: <1447970316.22599.257.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
	 <20130311000216.GA31808@zoreil.com>
	 <20130405001526.GC19253@marvin.atrad.com.au>
	 <20151117015605.GI22941@marvin.atrad.com.au>
	 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
	 <20151118050919.GR25216@marvin.atrad.com.au>
	 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
	 <20151119065718.GT8170@marvin.atrad.com.au>
	 <1447935754.22599.194.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151119214416.GB30304@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Woithe <jwoithe@atrad.com.au>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35709 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbKSV6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:58:38 -0500
Received: by pacej9 with SMTP id ej9so93493026pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 13:58:38 -0800 (PST)
In-Reply-To: <20151119214416.GB30304@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 22:44 +0100, Francois Romieu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
> > This looks like a race when/if RX happens very shortly after one
> > transmit.
> > 
> > Francois, are we really saving lot of cpu cycles testing status ?
> 
> I'm not sure. An extra smp_rmb and three cache lines at most when
> there really isn't any work ? Probably not worth it.
> 
> Can you clarify which kind of race you're thinking about ?

I was mostly thinking of some hardware bug.

Or maybe a software barrier is missing, but I could not see it.

(Assuming rtl_get_events() is accurate, ie really returns a mask of
pending events in all circumstances, including if run in // from
rtl_slow_event_work() and rtl8169_poll())
