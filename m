From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/1] net/hyperv: Add flow control based on hi/low
 watermark
Date: Tue, 27 Mar 2012 15:20:45 -0700
Message-ID: <20120327222045.GA469@kroah.com>
References: <1332886987-11613-1-git-send-email-haiyangz@microsoft.com>
 <1332886987-11613-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de,
	linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1332886987-11613-2-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2012 at 03:23:07PM -0700, Haiyang Zhang wrote:
> --- a/include/linux/hyperv.h
> +++ b/include/linux/hyperv.h
> @@ -274,6 +274,35 @@ struct hv_ring_buffer_debug_info {
>  	u32 bytes_avail_towrite;
>  };
>  
> +/* Amount of space to write to */
> +#define BYTES_AVAIL_TO_WRITE(r, w, z) \
> +	(((w) >= (r)) ? ((z) - ((w) - (r))) : ((r) - (w)))
> +

That's a very bad #define to use in a .h file, please do not do that.

> +
> +/*
> + *
> + * hv_get_ringbuffer_availbytes()
> + *
> + * Get number of bytes available to read and to write to
> + * for the specified ring buffer
> + */
> +extern inline void
> +hv_get_ringbuffer_availbytes(struct hv_ring_buffer_info *rbi,
> +			  u32 *read, u32 *write)

What does "extern inline" mean?

Please fix.

greg k-h
