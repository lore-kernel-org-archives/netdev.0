From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Fri, 8 Jun 2012 09:43:12 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1206080940350.1360-100000@iolanthe.rowland.org>
References: <CA+v9cxbogzS7sVChqkRMgDUcs=aJgNDRH8ydoQ-_htfS2t52gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxbogzS7sVChqkRMgDUcs=aJgNDRH8ydoQ-_htfS2t52gQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Jun 2012, Huajun Li wrote:

> > If so, looks mistaken value is returned from the host controller driver,
> > but not sure if your device is buggy. What is your host controller?
> >
> Nothing related to HC.
> I tried to find out the endpoint state, but found it was halt. I think
> this is the root cause.

No, it isn't.  Endpoint halt causes a -EPIPE error, not -EPROTO.  
-EPROTO indicates that the device's firmware has crashed.

> What's your opinion to handle "-EPROTO" error in usbnet.c?
> Please check usbnet.c again, when "-EPROTO" occurs, it just pints
> error msg and re-submit the interrupt URB, and then causes endless
> "EactErr" error msg.

One possibility is to wait for a little while before resubmitting the 
URB, and after 10 failures in a row, attempt a reset.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
