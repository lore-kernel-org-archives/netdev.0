From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 16:17:25 +0800
Message-ID: <CACVXFVM7wPLXy0JL7QDnCaZFidwucTFf3t_38DuwukxWtOESHQ@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1765908.3QOFSVW2eC@linux-lqwf.site>
	<CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A@mail.gmail.com>
	<4085386.s0fOKMaRDP@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4085386.s0fOKMaRDP-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2012 at 1:51 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>
> No, the problem is autoresume.
>
> Suppose we have a device with two interface. Interface A be usbnet; interface B
> something you page on. Now consider that you can only resume both interfaces
> and this is (and needs to be) done synchronously.
>
> Now we can have this code path:
>
> autoresume of device -> resume() -> kmalloc(..., GFP_KERNEL) ->
> VM layer decides to start paging out -> IO to interface B -> autoresume of device
> --> DEADLOCK

OK, thanks for your detailed explanation.

> We need to use GFP_NOIO in situations the helper cannot know about.
> Please add a gfp_t parameter. Then the caller will solve that.

Considered that most of drivers call the helpers in different context, I think
it is better to switch the gpf_t flag runtime inside helpers, like below:

           if (dev->power.runtime_status == RPM_RESUMING)
                   gfp = GFP_NOIO;
          else
                   gfp = GFP_KERNEL;

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
