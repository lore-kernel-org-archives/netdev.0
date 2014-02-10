From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2 v2] usbnet: fix bad header length bug
Date: Mon, 10 Feb 2014 13:22:27 +0100
Message-ID: <1392034947.2082.30.camel@linux-fkkt.site>
References: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
	 <1392014458.21271.6.camel@linux-fkkt.site> <20140210115812.GA4278@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Glen Turner <gdt-pRLresKaOUyHXe+LvDLADg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Emil Goode <emilgoode-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140210115812.GA4278@lianli>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-02-10 at 13:00 +0100, Emil Goode wrote:
> On Mon, Feb 10, 2014 at 07:40:58AM +0100, Oliver Neukum wrote:
> > On Mon, 2014-02-10 at 00:06 +0100, Emil Goode wrote:
> > > The AX88772B occasionally send rx packets that cross urb boundaries
> > > and the remaining partial packet is sent with no hardware header.
> > > When the buffer with a partial packet is of less number of octets
> > > than the value of hard_header_len the buffer is discarded by the
> > > usbnet module. This is causing dropped packages and error messages
> > > in dmesg.
> > > 
> > > This can be reproduced by using ping with a packet size
> > > between 1965-1976.
> > 
> > Well, then how about simply removing the check?
> > It seems to have outlived its usefulness.
> > 
> > 	Regards
> > 		Oliver
> > 
> >
> 
> I did consider that and I think it is probably the best thing to do.
> However, I think the removal of the check could have negative effects
> on the other minidrivers, at least the qmi_wwan minidriver explicitly
> states that it is depending on this check to be made in rx_complete().

<censored>. Oh well. But how about merging it with FLAG_MULTI_PACKET?
I really don't want to add more flags. There is a point where enough
flags make absurd having a common code. We are closing in on that point.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
