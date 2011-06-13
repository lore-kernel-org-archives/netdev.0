From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Mon, 13 Jun 2011 10:19:23 -0500
Message-ID: <1307978364.2117.11.camel@dcbw.foobar.com>
References: <1307748870-12950-1-git-send-email-marius@kotsbak.com>
	 <1307977039.2117.7.camel@dcbw.foobar.com> <4DF62656.8060506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DF62656.8060506-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-06-13 at 17:01 +0200, Marius Kotsbak wrote:
> On 13. juni 2011 16:57, Dan Williams wrote:
> > On Sat, 2011-06-11 at 01:34 +0200, Marius B. Kotsbak wrote:
> >> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
> >> It has also an ACM interface that previous patches associates with the "option"
> >> module. To access those interfaces, the modem must first be switched from modem
> >> mode using a tool like usb_modeswitch.
> >>
> >> As the proprietary protocol has been discovered by watching the MS Windows driver
> >> behavior, there might be errors in the protocol handling, but stable and fast
> >> connection has been established for hours with Norwegian operator NetCom that
> >> distributes this modem with their LTE/4G subscription.
> > Why make the driver bind to both the switched and unswitched USB IDs?
> > Shouldn't the kernel bind the driver after switch when the device
> > reconnects with the new IDs?
> 
> No, I tried and it did not happen, so I assumed that the kernel modules
> are only loaded at USB insertion event, not when the interfaces changes.
> Does anyone here know if my observation is right?
> 
> Usb_modeswitch autoloads "option" module after switching, but not my
> kalmia module.

Try killing the modeswitch autoload thing first by moving the udev
script out of the way.  Then plug your device in, and run
"usb-modeswitch -c /path/to/config" so that the usb_modeswitch autoload
thing doesn't run.  Does that work?  I don't want to slander
usb_modeswitch but I've seen some odd behavior which I suspect is it's
module force-loading feature, though I haven't investigated too much
yet.  But ruling that out could be helpful.

Dan


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
