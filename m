From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 11:41:56 -0700
Message-ID: <20080421184157.106603602C8@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <20080417214719.GF17664@kroah.com>
 <480BE815.2000409@teltonika.lt> <200804211016.02819.oliver@neukum.org>
 <480C5FAF.1050408@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480C5FAF.1050408-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
> Date: Mon, 21 Apr 2008 12:34:39 +0300
>
> IMO it doesn't make sense to do multicasting since actually it is
> point-to-point and not ethernet traffic.
> Currently I am studying if it is possible to convert current pseudo
> ethernet interface to point-to-point one.

For the record:  when I looked at that issue with respect to USB
network connections for handheld devices, one issue seemed to be
weak support for managing (lots of) point-to-point links.

The example that sticks in my memory is that of routing.  Setting
up a point to point link between a handheld and a PC required
the PC to act as an IP router.  Managing lots of desktop routers
in any large configuration seemed to be a losing game ... and
one that many network administrators would refuse to play.  And
that's in addition to the lack of a dynamic IP address assignment
solution for lots of point-to-point links.

The alternative was to set up the links like Ethernet, then bridge
them.  That's a *much* more manageable solution, even though I still
don't know of any distro that makes bridge setup work as easily as
Windows does (sigh).  Bridging properly requires the ability to handle
multicast and broadcast packets ... and once you've got that then
DHCP, zeroconf, and other automatic network configuration schemes
work easily.

QED ... that's why the "usbnet" framework doesn't try to use the
point-to-point framework, instead allows N-casting.

- Dave

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
