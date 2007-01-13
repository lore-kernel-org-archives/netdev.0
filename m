From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sat, 13 Jan 2007 20:51:52 +0100
Message-ID: <200701132051.52559.mb@bu3sch.de>
References: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
	<200701131509.26877.mb@bu3sch.de>
	<20070113143033.fi804so8ok04wc4k@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <20070113143033.fi804so8ok04wc4k-2RFepEojUI3Rd1RZctBqVdHuzzzSOjJt@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 13 January 2007 20:30, Pavel Roskin wrote:
> Quoting Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>:
> 
> > I looked more closely at it, but I really can't see why it oopses.
> > Any idea what's happening there?
> 
> I haven't looked at the code yet, but I tried to locate the bad commit.  I tried
> commit a13f85d8a8eb40dfd157ab78c2fb91b5765b7b9d, which is your last merge, just
> before the SSB changes.

Yeah, sure. I know that this is the commit which introduced this.

> The kernel doesn't oops anymore!  But it doesn't connect either.  I reconfigured
> the AP to use WPA-PSK with TKIP.  MadWifi works with it, but bcm43xx fails in
> the same configuration.  The wireless-dev tip has the same problem.

Note that LO calibration is horribly broken in my tree.
So you have a very weak signal, if any. My 4318 has no signal, for example.
So basically don't expect to be able to transmit any data.
This includes association.

But I think you should be able to assoc with a plain linville tree.

> So, the oops was introduced in the transition to the new SSB. 
> bcm43xx_setup_dmaring(), which appears in the stack dump, is affected by the
> patch.

Yeah, but I don't see where we can get such an oops from :)

> I'll try to look closely at the changes.  My immediate suspect is that we have
> too many different fields called "dev".  All it takes is one cast to hide a
> horrible mistake.  Although I think it would have affected you as well (unless

We don't cast devs.

> it's casts to/from integers, something that won't be a problem on 32-bit
> kernels).

dito.

> > Well, ok. So it should work in my tree, too, once we fixed the DMA oops.
> 
> You mean there is a reason for me to think that your changes would fix
> accociation to the AP?

No.


We oops in dma_alloc_coherent, right?
Where can we get a NULL pointer there? I don't see it. Any idea?
Also, regarding to the oops message, it's oopsing somewhere at
the beginning of the function.

-- 
Greetings Michael.
