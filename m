From: Greg KH <greg@kroah.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 14 Jul 2010 02:49:52 -0700
Message-ID: <20100714094952.GA16209@kroah.com>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org> <201005051035.29831.dtor@vmware.com> <20100505173951.GA8388@infradead.org> <20100505105253.0a8bc465@nehalam> <20100506202113.GC17922@infradead.org> <1278990388.32650.22.camel@eng-rhel5-64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1278990388.32650.22.camel@eng-rhel5-64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 12, 2010 at 08:06:28PM -0700, Shreyas Bhatewara wrote:
>  drivers/net/vmxnet3/vmxnet3_drv.c     | 1845
> +++++++++++++++++++--------------

Your patch is line-wrapped and can not be applied :(

Care to fix your email client?

One thing just jumped out at me when glancing at this:

> +static INLINE void
> +MoveMemory(void *dst,
> +		void *src,
> +		size_t length)
> +{
> +	size_t i;
> +	for (i = 0; i < length; ++i)
> +		((u8 *)dst)[i] = ((u8 *)src)[i];
> +}
> +
> +static INLINE void
> +ZeroMemory(void *memory,
> +		size_t length)
> +{
> +	size_t i;
> +	for (i = 0; i < length; ++i)
> +		((u8 *)memory)[i] = 0;
> +}

Is there some reason that our in-kernel functions that do this type of
logic are not working for you to require you to reimplement this?

thanks,

greg k-h
