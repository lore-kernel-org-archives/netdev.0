From: "Scott M. Ferris" <sferris@acm.org>
Subject: Re: TSO prevents cwnd growth on 2.6 kernels
Date: Fri, 25 Mar 2005 13:34:59 -0600
Message-ID: <20050325193458.GA15645@visi.com>
References: <20050325181804.GA11633@visi.com> <20050325104000.713229be.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Scott M. Ferris" <sferris@acm.org>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050325104000.713229be.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2005 at 10:40:00AM -0800, David S. Miller wrote:
>
> We know it's busted.  I haven't gotten to fixing this stuff
> up yet.

Perhaps TSO should default to off for all drivers then?  I hadn't even
noticed it was enabled until after I was debugging the problem.

> Are you suggesting to let it go past tp->snd_cwnd?  We can't
> ever do that.  tp->snd_cwnd is a hard limit on the number
> of frames we may have outstanding on the network at one time,
> TSO or not.

No, I think we all agree that exceeding cwnd is a bad idea.  I'm just
saying that failing to reach cwnd is also broken, especially if it
results in tcp_write_xmit() sending nothing at all when cwnd is small.

-- 
Scott M. Ferris,
sferris@acm.org 
