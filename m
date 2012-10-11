From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Thu, 11 Oct 2012 11:18:22 +0800
Message-ID: <CACVXFVMynoPm6_wYj2MD-5SvMpB7e1Wk94=XMp588rD8hU=eew@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1765908.3QOFSVW2eC@linux-lqwf.site>
	<CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A@mail.gmail.com>
	<4085386.s0fOKMaRDP@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
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

Currently scsi disk can only be runtime suspended when the device is not
opened, so are you sure that the paging out above can cause IO on a suspend
usb mass storage disk which is not mounted or opened by utility now?


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
