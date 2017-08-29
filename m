From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next] staging: irda: force to be a kernel module
Date: Tue, 29 Aug 2017 19:31:29 +0200
Message-ID: <20170829173129.GA11029@kroah.com>
References: <20170829070929.GA15824@kroah.com>
 <20170829091417.GA9481@kroah.com>
 <20170829.093507.2166038228205751885.davem@davemloft.net>
 <20170829172608.GA4700@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        samuel@sortiz.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829172608.GA4700@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 07:26:08PM +0200, Greg KH wrote:
> On Tue, Aug 29, 2017 at 09:35:07AM -0700, David Miller wrote:
> > From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Date: Tue, 29 Aug 2017 11:14:17 +0200
> > 
> > > Now that the IRDA networking code has moved into drivers/staging/, the
> > > link order is changed for when it is initialized if built into the
> > > system.  This can cause a crash when initializing as the netfilter core
> > > hasn't been initialized yet.
> > > 
> > > So force the IRDA code to be built as a module, preventing the crash.
> > > 
> > > Reported-by: kernel test robot <fengguang.wu@intel.com>
> > > Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org
> > 
> > I don't think this is reasonable.
> > 
> > IRDA being built in was broken by moving it to staging, so it's a
> > regression and we should find a way to fix it.
> 
> Hm, this is due to netlink coming before irda in the link order before
> this patch series.  I can't change the link order to put all of net/
> before drivers/, which would solve this, and I don't think I can put:
> 	obj-$(CONFIG_IRDA) += ../../drivers/staging/irda/net/
> in a networking Makefile, can I?  Does "../" even work in a Makefile
> like that?

Wait, I think that does work, let me go test this some more...

thanks,

greg k-h-
