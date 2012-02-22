From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] usb/core: remove "always" from usb_unlink_urb() kernel
 doc entry
Date: Wed, 22 Feb 2012 15:28:53 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1202221525210.1311-100000@iolanthe.rowland.org>
References: <20120222194510.GA6964@linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120222194510.GA6964-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Feb 2012, Sebastian Andrzej Siewior wrote:

> The kernel doc entry for usb_unlink_urb() contains the phrase "This
> request is always asynchronous.". The "always" leads to the assumption
> that the ->complete() callback is not called from within
> usb_unlink_urb(). This is not true. The HCD is allowed to call the
> ->complete() from within ->urb_dequeue() if it is appropriate for the
> hardware.
> This patch updates the kernel doc so usb-device driver authors make sure
> to drop all locks (and make sure it is okay to drop them) which are
> acquired by the complete callback before calling usb_unlink_urb().
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> ---
>  drivers/usb/core/urb.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/usb/core/urb.c b/drivers/usb/core/urb.c
> index f4f20c7..d72b376 100644
> --- a/drivers/usb/core/urb.c
> +++ b/drivers/usb/core/urb.c
> @@ -527,10 +527,11 @@ EXPORT_SYMBOL_GPL(usb_submit_urb);
>   * a driver's I/O routines to insure that all URB-related activity has
>   * completed before it returns.
>   *
> - * This request is always asynchronous.  Success is indicated by
> - * returning -EINPROGRESS, at which time the URB will probably not yet
> - * have been given back to the device driver.  When it is eventually
> - * called, the completion function will see @urb->status == -ECONNRESET.
> + * This request is asynchronous, however the hcd might call the ->complete()
> + * callback during unlink.

"Therefore when drivers call usb_unlink_urb(), they must not hold any
locks that may be taken by the completion function."

Also, we write "HCD" in capital letters.

>  Success is indicated by returning -EINPROGRESS, at
> + * which time the URB will probably not yet have been given back to the device
> + * driver. When it is eventually called, the completion function will see
> + * @urb->status == -ECONNRESET.
>   * Failure is indicated by usb_unlink_urb() returning any other value.
>   * Unlinking will fail when @urb is not currently "linked" (i.e., it was
>   * never submitted, or it was unlinked before, or the hardware is already

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
