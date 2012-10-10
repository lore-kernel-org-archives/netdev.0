From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 12/12] usbnet: make device out of suspend before calling usbnet_read/write_cmd
Date: Wed, 10 Oct 2012 07:34:48 +0200
Message-ID: <4592082.DQ2vghozbC@linux-lqwf.site>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com> <2913414.gCAxlQ38lG@linux-lqwf.site> <CACVXFVNb-APsJG=ejW+2jqxTfAFsGhHovpgpsyvk6wUoKn5TzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNb-APsJG=ejW+2jqxTfAFsGhHovpgpsyvk6wUoKn5TzA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 October 2012 10:33:17 Ming Lei wrote:
> On Tue, Oct 9, 2012 at 4:50 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> > This is awkward to use in suspend()/resume()
> > Could you make both versions available?
> 
> Good catch, thanks for your review.
> 
> As far as I can think of, the mutex_is_locked() trick can solve the problem.

No, you cannot do this. It introduces a race. The check for mutex_is_locked()
can be positive because the device is being suspended and the IO would
be done when it is too late.
Please don't try to be fancy here, just export two versions of each call.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
