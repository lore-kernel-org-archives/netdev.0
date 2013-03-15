From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCH v3 2/7] USB: serial: comments on suspend failure
Date: Fri, 15 Mar 2013 10:02:06 +0100
Message-ID: <20130315090206.GA28843@localhost>
References: <1363320539-23012-1-git-send-email-ming.lei@canonical.com>
 <1363320539-23012-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org,
	Johan Hovold <jhovold@gmail.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363320539-23012-3-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 15, 2013 at 12:08:54PM +0800, Ming Lei wrote:
> If suspend callback fails in system sleep context, usb core will
> ignore the failure and let system sleep go ahead further, so
> this patch comments on the case and requires that serial->type->suspend()
> MUST return 0 in system sleep context.
> 
> Cc: Johan Hovold <jhovold@gmail.com>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/usb/serial/usb-serial.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/usb/serial/usb-serial.c b/drivers/usb/serial/usb-serial.c
> index a19ed74..16eb02b 100644
> --- a/drivers/usb/serial/usb-serial.c
> +++ b/drivers/usb/serial/usb-serial.c
> @@ -1140,6 +1140,11 @@ int usb_serial_suspend(struct usb_interface *intf, pm_message_t message)
>  
>  	serial->suspending = 1;
>  
> +	/*
> +	 * serial->type->suspend() MUST return 0 in system sleep context,
> +	 * otherwise, the resume callback has to recover device from
> +	 * previous suspend failure.
> +	 */
>  	if (serial->type->suspend) {
>  		r = serial->type->suspend(serial, message);
>  		if (r < 0) {

Acked-by: Johan Hovold <jhovold@gmail.com>

Thanks,
Johan
