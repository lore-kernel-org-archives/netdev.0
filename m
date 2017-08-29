From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next] staging: irda: force to be a kernel module
Date: Tue, 29 Aug 2017 19:26:08 +0200
Message-ID: <20170829172608.GA4700@kroah.com>
References: <20170829070929.GA15824@kroah.com>
 <20170829091417.GA9481@kroah.com>
 <20170829.093507.2166038228205751885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829.093507.2166038228205751885.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 09:35:07AM -0700, David Miller wrote:
> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Date: Tue, 29 Aug 2017 11:14:17 +0200
> 
> > Now that the IRDA networking code has moved into drivers/staging/, the
> > link order is changed for when it is initialized if built into the
> > system.  This can cause a crash when initializing as the netfilter core
> > hasn't been initialized yet.
> > 
> > So force the IRDA code to be built as a module, preventing the crash.
> > 
> > Reported-by: kernel test robot <fengguang.wu@intel.com>
> > Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org
> 
> I don't think this is reasonable.
> 
> IRDA being built in was broken by moving it to staging, so it's a
> regression and we should find a way to fix it.

Hm, this is due to netlink coming before irda in the link order before
this patch series.  I can't change the link order to put all of net/
before drivers/, which would solve this, and I don't think I can put:
	obj-$(CONFIG_IRDA) += ../../drivers/staging/irda/net/
in a networking Makefile, can I?  Does "../" even work in a Makefile
like that?

Any other thoughts?

> It's one thing if IRDA on it's own has deteriorated and broken in some
> ways over time due to lack of maintainence, it's another to knowingly
> do something to it that causes a regression which is what happened
> here.

It has deteriorated and is broken and does not work at all from the
reports I have gotten, Linus pointing this out to me directly due to his
involvement in irda-related dive computers.  So I don't think anyone is
using this at all right now, it seems to crash when used anyway.  So no
one is running this "build in" code at the moment :)

ideas?

thanks,

greg k-h
