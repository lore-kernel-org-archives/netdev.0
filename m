From: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH v3 3/5] usbnet: smsc95xx: fix memory leak in smsc95xx_suspend
Date: Tue, 6 Nov 2012 13:20:44 +0000
Message-ID: <CAKh2mn52HCFE8JSRJZ95m8qimPP0d4hx8SP3yExTsi+RYfJwRg@mail.gmail.com>
References: <1352166341-27616-1-git-send-email-ming.lei@canonical.com>
	<1352166341-27616-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1352166341-27616-4-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6 November 2012 01:45, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> This patch fixes memory leak in smsc95xx_suspend.

Good spot, thanks!

Note that check_warn_return just above your kfree can cause early
return in the error case, which would still leak filter_mask, so we
might want to explicitly expand that instance of the helper macro.

> Also, it isn't necessary to bother mm to allocate 8bytes/16byte,
> and we can use stack variable safely.

Acked-By: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
