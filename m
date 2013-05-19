From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 4/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sun, 19 May 2013 11:53:29 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305191149310.4537@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305181905100.7518@fry.nucleusys.com> <20130518211012.GC26590@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463786495-1647968027-1368953615=:4537"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130518211012.GC26590@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463786495-1647968027-1368953615=:4537
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: 8BIT

On Sat, 18 May 2013, Francois Romieu wrote:

> Petko Manolov <petkan@nucleusys.com> :
> [...]
> >  static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
> >  {
> > -	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
> > -			       RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
> > -			       indx, 0, data, size, 500);
> > +	int res;
> > +
> > +	res = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
> > +			      RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
> > +			      indx, 0, data, size, 500);
> > +	if (res < 0)
> > +		dev_dbg(&dev->udev->dev, "%s returned %d\n", __func__, res);
> > +	return res;
> 
> You may move it into a separate patch. It is completely unrelated to the
> ctrl_urb changes.

The change is so trivial i thought i can smuggle it unnoticed. :-)

> [...]
> > +static int async_set_registers(rtl8150_t *dev, u16 indx, u16 size, u16 reg)
> >  {
> 
> [...]
> > +	usb_fill_control_urb(async_urb, dev->udev,
> > +	                     usb_sndctrlpipe(dev->udev, 0), (void *) &req->dr,
> 
> Useless void * cast.

Wrong.  The compiler actually moans quite a lot:

/usr/src/git/rtl8150/rtl8150.c: In function ¡async_set_registers¢:
/usr/src/git/rtl8150/rtl8150.c:92:9: warning: passing argument 4 of ¡usb_fill_control_urb¢ from incompatible pointer type [enabled by default]
In file included from /usr/src/git/rtl8150/rtl8150.c:17:0:
include/linux/usb.h:1440:20: note: expected ¡unsigned char *¢ but argument is of type ¡struct usb_ctrlrequest *¢
---1463786495-1647968027-1368953615=:4537--
