From: Andrew Morton <akpm@osdl.org>
Subject: Re: kernel BUG at page_alloc.c:98 -- compiling with distcc
Date: Thu, 29 Apr 2004 14:28:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040429142807.1fa4c5ea.akpm@osdl.org>
References: <382320000.1082759593@taltos.ny.ficc.gs.com>
	<16527.4259.174536.629347@segfault.boston.redhat.com>
	<20040429210951.GB20453@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmoyer@redhat.com, carson@taltos.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, andrea@suse.de, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
In-Reply-To: <20040429210951.GB20453@logos.cnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> > Andrea fixed this in his tree by deferring the page free to process context
> > instead of BUG()ing on PageLRU(page).
> 
> Yeap, his fix looks OK.

It does.

It would be nice to change

	if (in_interrupt())

to

	if (in_interrupt() || ((count++ % 10000) == 0))

just to exercise that code path a bit more.
