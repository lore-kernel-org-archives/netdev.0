From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 2/2] ipv4 igmp: use del_timer_sync instead of del_timer in ip_mc_down
Date: Sat, 28 Sep 2013 03:15:32 +0400
Message-ID: <20130927231532.GA23750@ms2.inr.ac.ru>
References: <1378363404-37749-1-git-send-email-noureddine@aristanetworks.com> <20130905084312.091f73b7@nehalam.linuxnetplumber.net> <CAO7SqHA4LJhy_NBkPLViJB3s7hM85qd88pmjy3hq-hCCuQstaA@mail.gmail.com> <CAO7SqHA5pBs7Tmop1ukS_AEXO8K9Np7odo20QdTYHBg2qoV49Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:44131 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754204Ab3I1AOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 20:14:03 -0400
Content-Disposition: inline
In-Reply-To: <CAO7SqHA5pBs7Tmop1ukS_AEXO8K9Np7odo20QdTYHBg2qoV49Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 04:04:00PM -0700, Salam Noureddine wrote:
> 				I don't quite understand the reason
> for having __in_dev_put decrement the refcnt without destroying the
> in_device in case it reaches 0. If the timer handler assumes it cannot
> be the last one to hold a reference then that would mean it doesn't
> need the reference in the first place.

I would like to explain this, because this can result in a big mistake.

Timer takes reference, when it _can_ be the last sometimes.

When we do del_timer() and know for sure that someone holds refcnt, we can just
decrese it. In this cae it is obvious: we sit in context whcih deals with in_dev,
so that reference from timer acannot be the last: caller of the function holds refcnt.

But in another places timer _expires_ and that last reference is dropped by in_dev_put().

Alexey
