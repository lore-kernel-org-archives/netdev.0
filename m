From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] socket.7: add description for SO_BUSY_POLL
Date: Mon, 20 Jan 2014 17:28:54 +0100
Message-ID: <52DD4EC6.7080208@gmail.com>
References: <20130710141835.15799.61657.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eliezer Tamir <eliezer-rsSRdLmRgNEQhDRD3CWCHA@public.gmane.org>
To: Eliezer Tamir <eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130710141835.15799.61657.stgit-vd+Q285fAQQAP1VksDEriRL4W9x8LtSr@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/10/2013 04:18 PM, Eliezer Tamir wrote:
> Add description for the SO_BUSY_POLL socket option to the socket(7) manpage.

Long after the fact, I've applied this. Thanks, Eliezer.

Would you be willing also to write a patch for the POLL_BUSY_LOOP flag of 
poll()?

Cheers,

Michael


> v2
> fixed typos reported by Rasmus Villemoes
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> ---
> 
>  man7/socket.7 |   25 +++++++++++++++++++++++++
>  1 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/man7/socket.7 b/man7/socket.7
> index f2213eb..5edcb09 100644
> --- a/man7/socket.7
> +++ b/man7/socket.7
> @@ -694,6 +694,31 @@ for details on control messages.
>  Gets the socket type as an integer (e.g.,
>  .BR SOCK_STREAM ).
>  This socket option is read-only.
> +.TP
> +.B SO_BUSY_POLL
> +Sets the approximate time in microseconds to busy poll on a blocking receive
> +when there is no data. Increasing this value requires
> +.BR CAP_NET_ADMIN . 
> +The default for this option is controlled by the
> +.I /proc/sys/net/core/busy_read
> +file. 
> +
> +The value in the  
> +.I /proc/sys/net/core/busy_poll
> +file determines how long 
> +.BR select (2)
> +and 
> +.BR poll (2)
> +will busy poll when they operate on sockets with 
> +.BR SO_BUSY_POLL
> +set and no events to report are found.
> +
> +In both cases busy polling will only be done when the socket last received data
> +from a network device that supports this option.
> +
> +While busy polling may improve latency of some applications, care must be
> +taken when using it since this will increase both CPU utilization and power usage.
> +
>  .SS Signals
>  When writing onto a connection-oriented socket that has been shut down
>  (by the local or the remote end)
> 
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
