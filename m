From: "David S. Miller" <davem@davemloft.net>
Subject: Re: serious netpoll bug w/NAPI
Date: Wed, 16 Feb 2005 15:54:07 -0800
Message-ID: <20050216155407.3dbcd9d6.davem@davemloft.net>
References: <20050208201634.03074349.davem@davemloft.net>
	<20050209183219.GA2366@waste.org>
	<20050209164658.409f8950.davem@davemloft.net>
	<20050210011104.GF2366@waste.org>
	<16914.31886.665975.522710@segfault.boston.redhat.com>
	<20050216050722.GC3358@waste.org>
	<20050216150236.61ca5faf.davem@davemloft.net>
	<20050216234406.GA3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmoyer@redhat.com, netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050216234406.GA3120@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Feb 2005 15:44:06 -0800
Matt Mackall <mpm@selenic.com> wrote:

> Ok. We've got a few cases:
> 
> 1) recursion on cpu1

If you hit this case, and therefore can't re-enter into ->poll(),
you must drop the packet or so something else if netif_queue_stopped()
since netpoll has no means by which to cause the TX queue to make
forward progress.

Do you at least agree with this?

Perhaps you can create a "pending netpoll() packet" queue so that
you don't have to drop the SKB in this case.  Make the queue get
processed via softint processing.  I think this will work.
