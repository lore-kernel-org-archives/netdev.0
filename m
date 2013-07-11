From: Devin Heitmueller <dheitmueller@kernellabs.com>
Subject: Re: [PATCH 36/50] media: usb: em28xx: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 08:42:49 -0400
Message-ID: <CAGoCfizP6ZKeK1Kw+pjZ+mqxE6J2fM_JBhME=3Q6qRP0NfPX5A@mail.gmail.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
	<1373533573-12272-37-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Mauro Carvalho Chehab <mchehab@redhat.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1373533573-12272-37-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 11, 2013 at 5:05 AM, Ming Lei <ming.lei@canonical.com> wrote:
> Complete() will be run with interrupt enabled, so change to
> spin_lock_irqsave().
>
> Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
> Cc: linux-media@vger.kernel.org
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/media/usb/em28xx/em28xx-core.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/media/usb/em28xx/em28xx-core.c b/drivers/media/usb/em28xx/em28xx-core.c
> index fc157af..0d698f9 100644
> --- a/drivers/media/usb/em28xx/em28xx-core.c
> +++ b/drivers/media/usb/em28xx/em28xx-core.c
> @@ -941,6 +941,7 @@ static void em28xx_irq_callback(struct urb *urb)
>  {
>         struct em28xx *dev = urb->context;
>         int i;
> +       unsigned long flags;
>
>         switch (urb->status) {
>         case 0:             /* success */
> @@ -956,9 +957,9 @@ static void em28xx_irq_callback(struct urb *urb)
>         }
>
>         /* Copy data from URB */
> -       spin_lock(&dev->slock);
> +       spin_lock_irqsave(&dev->slock, flags);
>         dev->usb_ctl.urb_data_copy(dev, urb);
> -       spin_unlock(&dev->slock);
> +       spin_unlock_irqrestore(&dev->slock, flags);
>
>         /* Reset urb buffers */
>         for (i = 0; i < urb->number_of_packets; i++) {
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I actually stumbled across this a couple of weeks ago, and have had an
identical patch running in a local dev tree.

Reviewed-by: Devin Heitmueller <dheitmueller@kernellabs.com>
Tested-by: Devin Heitmueller <dheitmueller@kernellabs.com>

-- 
Devin J. Heitmueller - Kernel Labs
http://www.kernellabs.com
