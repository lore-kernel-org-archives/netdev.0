From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/5] usb: cdc-ncm: Set altsetting only when network
 interface is opened
Date: Fri, 17 Feb 2012 10:57:16 +0100
Message-ID: <CAL_Kpj01s=jCr5wkyaLanFUGFO4bsUcgHt+vP9W9mKAPA4Sh5Q@mail.gmail.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
	<1329317261-3406-3-git-send-email-toby.gray@realvnc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Toby Gray <tg-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1329317261-3406-3-git-send-email-toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2012 at 3:47 PM, Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org> wrote:

> Some NCM devices fail to send the NetworkConnection status if the host
> is not trying to read from the control interrupt endpoint in the first
> few seconds after the data interface alternate setting is selected.

I have a feeling that the problem description above is not correct:
more likely the fault is related to device initialization or other
state machine problem in device.

Looking at the trace, the patch serves its purpose, however there
might be other devices which can't get network status in time or get
similar problem. If this would be the case, driver could set a timer
after selecting alt1; in the absence of the connect message set alt0
to reset a function when timer expires and set alt1 again.

Regards,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
