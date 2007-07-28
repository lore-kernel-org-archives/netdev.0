From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH] USB Pegasus driver - avoid a
	potential NULL pointer dereference.
Date: Sun, 29 Jul 2007 05:07:54 +0530
Message-ID: <a781481a0707281637n5b123e4aib46c4e4b009b0018@mail.gmail.com>
References: <200707290019.02591.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <greg@kroah.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Petko Manolov <petkan@users.sourceforge.net>,
	linux-usb-devel@lists.sourceforge.net
To: "Jesper Juhl" <jesper.juhl@gmail.com>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200707290019.02591.jesper.juhl@gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

On 7/29/07, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> Hello,
>
> This patch makes sure we don't dereference a NULL pointer in
> drivers/net/usb/pegasus.c::write_bulk_callback() in the initial
> struct net_device *net = pegasus->net; assignment.
> The existing code checks if 'pegasus' is NULL and bails out if
> it is, so we better not touch that pointer until after that check.
> [...]
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index a05fd97..04cba6b 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -768,11 +768,13 @@ done:
>  static void write_bulk_callback(struct urb *urb)
>  {
>         pegasus_t *pegasus = urb->context;
> -       struct net_device *net = pegasus->net;
> +       struct net_device *net;
>
>         if (!pegasus)
>                 return;
>
> +       net = pegasus->net;
> +
>         if (!netif_device_present(net) || !netif_running(net))
>                 return;

Is it really possible that we're called into this function with
urb->context == NULL? If not, I'd suggest let's just get rid of
the check itself, instead.

Satyam

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
