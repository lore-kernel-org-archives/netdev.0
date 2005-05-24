From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [1-2/6] ipw2100, ipw2200: patches to merge to kernel
Date: Tue, 24 May 2005 19:56:19 +0200
Message-ID: <20050524175619.GM15391@postel.suug.ch>
References: <20050524150711.01632672@griffin.suse.cz> <20050524151506.48e5db65@griffin.suse.cz> <20050524172416.GB10479@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, NetDev <netdev@oss.sgi.com>, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Jones <davej@redhat.com>
Content-Disposition: inline
In-Reply-To: <20050524172416.GB10479@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Dave Jones <20050524172416.GB10479@redhat.com> 2005-05-24 13:24
> On Tue, May 24, 2005 at 03:15:06PM +0200, Jiri Benc wrote:
>  > Patches to merge the ipw2100 and ipw2200 drivers to the kernel can be
>  > downloaded from:
>  > http://jikos.cz/~jbohac/wifi/import-ipw2100.patch
>  > http://jikos.cz/~jbohac/wifi/import-ipw2200.patch
>  > (they are too large to post them here)
>  > 
>  > The ipw2100 patch is just a merge of ipw2100 driver with Pavel Machek's
>  > cleanup patch.
> 
> It contains a number of bogus uses of HZ.
> 
> +		IPW_DEBUG_INFO("Command completion failed out after %dms.\n",
> +			       HOST_COMPLETE_TIMEOUT / (HZ / 100));
> 
> ..
> 
> +	schedule_timeout(HZ / 100);
> 
> ..
> 
> What I don't understand, is that HZ in kernel-code should be 1000
> according to <asm/param.h>,  though for some reason, I've seen
> divide by zeros, and really strange oopses with this code.
> It's as if its for some reason, choosing to use the userspace HZ
> definition. Hmm, does it need an explicit include of <asm/param.h>
> perhaps ?

It should really use jiffies_to_msecs/usecs. HZ is < 100 on some
architectures and thus results in a division by 0, even it was safe,
the above code is inaccurate for some values of HZ.
