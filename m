From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] I/O space write barrier
Date: Wed, 29 Sep 2004 13:35:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929133500.59d78765.davem@davemloft.net>
References: <200409271103.39913.jbarnes@engr.sgi.com>
	<20040929103646.GA4682@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jbarnes@engr.sgi.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
        jeremy@sgi.com, johnip@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040929103646.GA4682@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 20:36:46 +1000
Greg Banks <gnb@sgi.com> wrote:

> Ok, here's a patch for the tg3 network driver to use mmiowb().  Tests
> over the last couple of days has shown that it solves the oopses in
> tg3_tx() that I reported and attempted to patch some time ago:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=108538612421774&w=2
> 
> The CPU usage of the mmiowb() approach is also significantly better
> than doing PCI reads to flush the writes (by setting the existing
> TG3_FLAG_MBOX_WRITE_REORDER flag).  In an artificial CPU-constrained
> test on a ProPack kernel, the same amount of CPU work for the REORDER
> solution pushes 85.1 MB/s over 2 NICs compared to 146.5 MB/s for the
> mmiowb() solution.

Please put this macro in asm/io.h or similar and make sure
every platform has it implemented or provides a NOP version.

A lot of people are going to get this wrong btw.  The only
way it's really going to be cured across the board is if someone
like yourself who understands this audits all of the drivers.
