From: Greg KH <greg@kroah.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 14 Jul 2010 13:20:37 -0700
Message-ID: <20100714202037.GA28821@kroah.com>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org> <201005051035.29831.dtor@vmware.com> <20100505173951.GA8388@infradead.org> <20100505105253.0a8bc465@nehalam> <20100506202113.GC17922@infradead.org> <F1354E79A137A24CBA60059AA65CB1B802A34EEB67@EXCH-MBX-2.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Pankaj Thakkar <pthakkar@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F1354E79A137A24CBA60059AA65CB1B802A34EEB67@EXCH-MBX-2.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 10:18:22AM -0700, Pankaj Thakkar wrote:
> The plugin is guest agnostic and hence we did not want to rely on any
> kernel provided functions. The plugin uses only the interface provided
> by the shell.

Really?  vmxnet3_plugin.c is no supposed to use any kernel-provided
functions at all?  Then why have it in the kernel at all?  Seriously,
why?

> The assumption is that since the plugin is really simple and straight
> forward (all the control/init complexity lies in the PF driver in the
> hypervisor) we should be able to get by for most of the things and for
> things like memcpy/memset the plugin can write simple functions like
> this.

If it's so simple, then why does it need to be separate?  Why not just
put it in your driver as-is to handle the ring-buffer logic (as that's
all it looks to be doing), and then you don't need any plugin code at
all?

It looks like you are linking this file into your "main" driver module,
so I fail to see any type of separation at all happening with this
patch.

Or am I totally missing something here?

thanks,

greg k-h
