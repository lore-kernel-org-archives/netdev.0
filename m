From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Mon, 11 Oct 2004 22:45:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011224542.5bdc93aa@jack.colino.net>
References: <20041007214505.GB31558@wotan.suse.de>
	<20041008090610.70d7e183@pirandello>
	<20041008220001.GE31237@waste.org>
	<20041008151839.01823e0c.akpm@osdl.org>
	<20041010205928.6e54df7e.davem@davemloft.net>
	<20041011154000.GB26350@wotan.suse.de>
	<20041011162224.GL31237@waste.org>
	<20041011163226.GG26350@wotan.suse.de>
	<20041011163601.GM31237@waste.org>
	<20041011164315.GH26350@wotan.suse.de>
	<20041011165851.GN31237@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041011165851.GN31237@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 11 Oct 2004 at 11h10, Matt Mackall wrote:

Hi, 

> Ergh, you deleted the context. Again, imagine we're originally in
> ->poll() for _a non-netpoll-related reason_. In other words, the
> console sem is not taken, because we're just doing routine network
> I/O. While in poll(), we take a private driver lock. Then for whatever
> reason, we printk -> netconsole -> netpoll -> poll() again where we
> attempt to retake the private driver lock.
> 
> > P.S.: I made the same mistake long ago, but akpm set me straight.
> 
> I'm pretty sure this case is different.

I tried replacing spin_lock by spin_trylock in poll() and a few other
functions (and returning accordingly), but it didn't help. I'm beginning
to think I won't be able to debug this one! ;)

-- 
Colin
  "When in doubt, do the right thing."
