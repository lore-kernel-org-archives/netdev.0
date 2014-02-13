From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH v2] usbnet: remove generic hard_header_len check
Date: Thu, 13 Feb 2014 18:29:08 +0100
Message-ID: <20140213172908.GA4250@lianli>
References: <1392310219-5719-1-git-send-email-emilgoode@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6BEF3A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Oliver Neukum <oneukum@suse.de>,
	=?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <edumazet@google.com>,
	Ming Lei <ming.lei@canonical.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Liu Junliang <liujunliang_ljl@163.com>,
	Octavian Purdila <octavian.purdila@intel.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6BEF3A@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 13, 2014 at 04:56:58PM +0000, David Laight wrote:
> From: Of Emil Goode
> > This patch removes a generic hard_header_len check from the usbnet
> > module that is causing dropped packages under certain circumstances
> > for devices that send rx packets that cross urb boundaries.
> > 
> > One example is the AX88772B which occasionally send rx packets that
> > cross urb boundaries where the remaining partial packet is sent with
> > no hardware header. When the buffer with a partial packet is of less
> > number of octets than the value of hard_header_len the buffer is
> > discarded by the usbnet module.
> ...
> > diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
> > index d6f64da..955df81 100644
> > --- a/drivers/net/usb/ax88179_178a.c
> > +++ b/drivers/net/usb/ax88179_178a.c
> > @@ -1118,6 +1118,10 @@ static int ax88179_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> >  	u16 hdr_off;
> >  	u32 *pkt_hdr;
> > 
> > +	/* This check is no longer done by usbnet */
> > +	if (skb->len < dev->net->hard_header_len)
> > +		return 0;
> > +
> 
> The ax88179 driver can also receive ethernet frames that cross the
> end of rx URB.
> It should have the code to save the last fragment (of a urb) until
> the next data arrives, and then correctly merge the fragments.
> 
> It is likely that any sub-driver that sets the receive urb length
> to a multiple of 1k (rather than leaving it at hard_hdr+mtu) can defrag
> rx data that crosses urb boundaries.

Yes probably the check is unnecessary to many of the devices but
it should be tested by someone who has the hardware.
If you have a ax88179 device to test this patch but without the
hard_header_len check added to the ax88179_rx_fixup function that
would be great. Then we don't need to introduce that check.

Best regards,

Emil Goode
