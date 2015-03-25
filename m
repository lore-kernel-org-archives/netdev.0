From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: RFC: Use of "jiffies" vs "jiffies64" in the neighbour system.
Date: Wed, 25 Mar 2015 11:27:04 +0100
Message-ID: <20150325102704.GB4673@unicorn.suse.cz>
References: <551289E1.8090609@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43390 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbbCYK1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 06:27:05 -0400
Content-Disposition: inline
In-Reply-To: <551289E1.8090609@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 11:11:45AM +0100, Ulf Samuelsson wrote:
> If you run HZ = 1000, then jiffies will wrap around after 49,71 days.
> This means that all time compares in the neighbour system will fail.
> 
> From what I can see from "jiffies,h" there is no attempt to detect
> the wrap-around.
> 
> #define time_after(a,b)        \
>     (typecheck(unsigned long, a) && \
>      typecheck(unsigned long, b) && \
>      ((long)(b) - (long)(a) < 0))
> #define time_before(a,b)    time_after(b,a)
> 
> #define time_after_eq(a,b)    \
>     (typecheck(unsigned long, a) && \
>      typecheck(unsigned long, b) && \
>      ((long)(a) - (long)(b) >= 0))
> #define time_before_eq(a,b)    time_after_eq(b,a)

I might have misunderstood you but those macros do handle the
wrap-around. For example, with 64-bit long and a = 1,
b = 0xffffffffffffffff, you get

  ((long)(b) - (long)(a)) = (-1) - (1) = -2 < 0

so that time_after(1, 0xffffffffffffffff) is true. It will give correct
results as long as the difference is less than half of range of the
type.

                                                         Michal Kubecek
