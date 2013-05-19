From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sun, 19 May 2013 21:01:27 +0200
Message-ID: <20130519190127.GB4019@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1305181905100.7518@fry.nucleusys.com>
 <20130518211012.GC26590@electric-eye.fr.zoreil.com>
 <alpine.DEB.2.02.1305191149310.4537@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305191149310.4537@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petko Manolov <petkan@nucleusys.com> :
[...]
> > > +	usb_fill_control_urb(async_urb, dev->udev,
> > > +	                     usb_sndctrlpipe(dev->udev, 0), (void *) &req->dr,
> > 
> > Useless void * cast.
> 
> Wrong.  The compiler actually moans quite a lot:
> 
> /usr/src/git/rtl8150/rtl8150.c: In function ?async_set_registers?:
> /usr/src/git/rtl8150/rtl8150.c:92:9: warning: passing argument 4 of ?usb_fill_control_urb? from incompatible pointer type [enabled by default]
> In file included from /usr/src/git/rtl8150/rtl8150.c:17:0:
> include/linux/usb.h:1440:20: note: expected ?unsigned char *? but argument is of type ?struct usb_ctrlrequest *?

Sorry, I confused it with transfer_buffer. Some drivers go through unsigned
char *, some widen it to void *.

-- 
Ueimor
