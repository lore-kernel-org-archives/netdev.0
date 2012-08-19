From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] serial: add a new helper function
Date: Sat, 18 Aug 2012 23:44:29 -0700
Message-ID: <20120819064429.GA3252@kroah.com>
References: <1345400832-23572-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@linux.intel.com, jirislaby@gmail.com,
	linux-kernel@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org
To: Huang Shijie <shijie8@gmail.com>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1345400832-23572-1-git-send-email-shijie8@gmail.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 19, 2012 at 02:27:12PM -0400, Huang Shijie wrote:
> --- a/include/linux/tty.h
> +++ b/include/linux/tty.h
> @@ -43,6 +43,7 @@
>  #include <linux/tty_driver.h>
>  #include <linux/tty_ldisc.h>
>  #include <linux/mutex.h>
> +#include <linux/serial.h>
>  
>  
>  
> @@ -513,6 +514,12 @@ static inline struct tty_port *tty_port_get(struct tty_port *port)
>  	return port;
>  }
>  
> +/* If the cts flow control is enabled, return true. */
> +static inline bool tty_port_cts_enabled(struct tty_port *port)
> +{
> +	return port->flags & ASYNC_CTS_FLOW;
> +}
> +

The fact that you have to add serial.h to this file kind of implies that
this function shouldn't be here, right?

How about serial.h instead?  Not all tty drivers are serial drivers :)

greg k-h
