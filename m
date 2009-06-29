From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [2.6.31-rc1] iwlagn (4965): regression when hardware rf switch is used
Date: Mon, 29 Jun 2009 11:48:54 +0200
Message-ID: <200906291148.55386.elendil@planet.nl>
References: <200906291128.05639.elendil@planet.nl> <1246268022.7775.24.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1246268022.7775.24.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 29 June 2009, Johannes Berg wrote:
> > [enable]
> > usb 3-1: new full speed USB device using uhci_hcd and address 3
> > usb 3-1: configuration #1 chosen from 1 choice
>
> That is completely unrelated. You plugged in a USB device too :)

No, it's my "bluetooth + wlan" device. Note that disabling wireless with 
the hardware switch also gives 'usb 3-1: USB disconnect, address 2'.

>From lsusb:
Bus 003 Device 002: ID 03f0:171d Hewlett-Packard Wireless (Bluetooth + 
WLAN) Interface [Integrated Module]

> > A lot uglier with those errors. And after that I have to run
> > ifdown/ifup before networking is up again (ifup only does not work as
> > it will complain "interface already configured"):
>
> And that's actually expected, and/or a bug in the debian networking
> scripts.
> (You can trigger the same problem by doing
> ifup wlan0
> ip link set wlan0 down
> ifup wlan0 -> error)

OK, I can accept that. Wonder why it does work with 2.6.30 then. But it 
can certainly wait until the driver problem you mentioned is resolved.

> To get your network connection back automatically we will require
> changes to userland tools to listen to rfkill events.
>
> > BTW, would it make sense to bring back the first two lines shown with
> > .30 (or at least the first one):
> >    iwlagn 0000:10:00.0: Radio Frequency Kill Switch is On:
> >    Kill switch must be turned off for wireless networking to work.
> > IMHO it's good to register the reason for the disconnect.
>
> I guess something like that could be added to cfg80211:
> phy0: taking interfaces down due to rfkill

Yes, that would be nice.

Thanks,
FJP
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
