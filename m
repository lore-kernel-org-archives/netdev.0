From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] USBNET: fix handling padding packet
Date: Mon, 11 Nov 2013 14:26:13 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73F8@saturn3.aculab.com>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com><878uyu6xjm.fsf@nemi.mork.no><CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com><87zjra5dpx.fsf@nemi.mork.no><1379523984.2430.3.camel@linux-fkkt.site><be5ecff3-27e1-4ab7-b3af-9d7c4376140f@email.android.com><1379573843.8608.7.camel@linux-fkkt.site><87wqmd46vj.fsf@nemi.mork.no> <CACVXFVPOyr3eDrJxGhmoxDdZS2FL17qm6jv0ezDECUAk267jFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Oliver Neukum" <oneukum-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"Network Development" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Ming Lei" <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	=?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <CACVXFVPOyr3eDrJxGhmoxDdZS2FL17qm6jv0ezDECUAk267jFg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> As my below test on ax99179_178a, I believe the patch should fix padding
> for dma sg, but need a little update, and I will send out v1 later:
> 
>            $ping -s 974 another_machine  #from host with ax99179_178a attached
> 
> If FLAG_SEND_ZLP is set for ax99179_178a, the above ping won't work any
> more either on USB3.0 or USB 2.0 host controller.
> 
> So don't assume that these brand new devices can support ZLP well.

I've just posted a fix to the xhci driver to implement URB_ZERO_PACKET.
With that fix (and ZLP enabled in the ax88179_178a driver) the above
ping works fine (ax88179 Ge card on USB3).

I wonder how many other usb drivers fail to support URB_ZERO_PACKET.
Maybe the driver should pass a flag to its users (along with SG support).

I've also posted (to linux-usb) another fix to the xhci driver that is
needed to get SG (and one that cross 64k boundaries) transfers working.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
