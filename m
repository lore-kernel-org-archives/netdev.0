From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] r8152: The Microsoft Surface docks also use R8152.
Date: Thu, 30 Mar 2017 13:12:42 -0500
Message-ID: <1490897562.24247.15.camel@redhat.com>
References: <20160113.145146.20282510666434086.davem@davemloft.net>
         <04D87F8E-0A8C-4DEC-AE66-35D9B6B0E7B7@exactcode.com>
         <20160113.154941.1886033351271894428.davem@davemloft.net>
         <20170328.064215.1055636797214516339.rene@exactcode.com>
         <1490893565.24247.9.camel@redhat.com>
         <D17D7867-DC1B-40FE-BA88-0B200EA86CF3@exactcode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, nic_swsd@realtek.com
To: =?ISO-8859-1?Q?Ren=E9?= Rebe <rene@exactcode.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55072 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933641AbdC3SMp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 14:12:45 -0400
In-Reply-To: <D17D7867-DC1B-40FE-BA88-0B200EA86CF3@exactcode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 19:47 +0200, René Rebe wrote:
> Hi,
> 
> On Mar 30, 2017, at 19:06, Dan Williams <dcbw@redhat.com> wrote:
> 
> > On Tue, 2017-03-28 at 06:42 +0200, Rene Rebe wrote:
> > > Without this the generic cdc_ether grabs the device,
> > > and does not really work.
> > 
> > Does this need a corresponding blacklist in cdc_ether
> > then?  Otherwise
> > you're really depending on driver loading order.
> 
> right, I already test build, and will send after reboot.
> 
> Any other nitpick in the meantime?

Nope, other than it's pretty odd that the device would expose standard
cdc-ether compatible USB descriptors, but apparently not be compatible
with cdc-ether?  Are we sure we don't just need a tweak or something to
cdc-ether?

Dan

> > Dan
> > 
> > > Signed-off-by: René Rebe <rene@exactcode.com>
> > > 
> > > diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> > > index c34df33..07f788c 100644
> > > --- a/drivers/net/usb/r8152.c
> > > +++ b/drivers/net/usb/r8152.c
> > > @@ -517,6 +517,7 @@ enum rtl8152_flags {
> > >  
> > >  /* Define these values to match your device */
> > >  #define VENDOR_ID_REALTEK              0x0bda
> > > +#define VENDOR_ID_MICROSOFT            0x045e
> > >  #define VENDOR_ID_SAMSUNG              0x04e8
> > >  #define VENDOR_ID_LENOVO               0x17ef
> > >  #define VENDOR_ID_NVIDIA               0x0955
> > > @@ -4521,6 +4522,8 @@ static void rtl8152_disconnect(struct
> > > usb_interface *intf)
> > >  static struct usb_device_id rtl8152_table[] = {
> > >         {REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
> > >         {REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
> > > +       {REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
> > > +       {REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07c6)},
> > >         {REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
> > >         {REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
> > >         {REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x3062)},
> > > 
> > > 
> > > -- 
> > >   René Rebe, ExactCODE GmbH, Lietzenburger Str. 42, DE-10789
> > > Berlin
> > >   http://exactcode.com | http://t2-project.org |
> > > http://rene.rebe.de
> 
> 
