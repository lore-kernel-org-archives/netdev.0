From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel header changes break glibc build
Date: Mon, 4 Dec 2006 10:13:41 +0100
Message-ID: <20061204091341.GM8693@postel.suug.ch>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19342 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1759822AbWLDJNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 04:13:20 -0500
To: David Woodhouse <dwmw2@infradead.org>
Content-Disposition: inline
In-Reply-To: <1165148731.12649.51.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Woodhouse <dwmw2@infradead.org> 2006-12-03 12:25
> Thomas, this is in response to your changes in
> http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=1823730fbc89fadde72a7bb3b7bdf03cc7b8835c;hp=47f68512d2685431f1781830dfcbab31bda87644
> in which you create <linux/if_addr.h> and require that it's included
> directly rather than being part of (or even included from)
> <linux/rtnetlink.h>. Was there a good reason for changing that
> user-visible header? Is there a reason not to include if_addr.h from
> rtnetlink.h as Joseph's patch does?

Userspace is not supposd to directly include kernel headers, instead
it has to make local copies and compile against them. Binary
compatibility is always guaranteed but in times of development within
a stable tree it's wrong to assume that headers never change.

I do not agree with the change to include if_addr.h in rtnetlink.h.
The point is to move bits apart and have multiple small pieces
of header files defining a specific rtnetlink family which are a
lot easier to maintain for both kernel and userspace than one giant
rtnetlink.h for everything.

> I suspect that if the IF{L,}A_{PAYLOAD,RTA} macros aren't used in the
> kernel then the best answer is for glibc to define those for itself.

Right, if they did it right they would only have noticed when they
updated the kernel headers to some newer versions and only had to
move the bits to some compat header.
