From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: AX88179_178A USB3 ethernet adapter performance issue
Date: Thu, 6 Feb 2014 09:12:39 -0800
Message-ID: <20140206171239.GB16792@xanatos>
References: <CAMVG2ssoBwk56n-k5VB9yO2LP4wc+gTv4o_17r-WYakwE6h2uQ@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B9A21@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Daniel J Blueman' <daniel-JCXMqzvhRcvYtjvyW6yDsg@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B9A21-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 06, 2014 at 03:39:02PM +0000, David Laight wrote:
> From: Daniel J Blueman
> > Hi Freddy et al,
> 
> I've copied this to linux-usb.
> 
> > I'm experiencing poor network performance using an ASIX AX88179_178A
> > USB3 to ethernet adapter using any recent linux kernel (eg 3.11),
> > using an Intel XHCI USB3 controller.
> 
> There a several problems with the xhci driver that show up when
> trying to use the ax88179_178a driver.
> Unfortunately some of the fixes have caused regressions on other
> host controllers with disk transfers.
> The patches may, or may not, be present in your kernel.
> The 'scatter-gather' support that is used in order to enable TSO
> is particularly good at exercising the buggy code paths.

Scatter gather was not added until 3.12.  That does not explain the
issues with a 3.11 kernel.  (Unless we're hitting the 64-KB boundary
corner case a lot in 3.11.)

> > Running iperf tests between one host with a gigabit PCIe NIC, via a
> > gigabit switch to the other host with various interfaces:
> > 
> > PCIe bcm957762: send 818Mb/s, recv 910Mb/s
> > USB2 smsc75xx: send 341Mb/s, recv 330Mb/s
> > USB3 ax88179_178a: send 347Mb/s, recv 18.7Mb/s
> > 
> > Are you able to reproduce the same 19Mb/s receive rate there?

Which kernel are these numbers for?

Any chance you can test this adapter on Windows?  I would be interested
to see whether the send and recv numbers are also asymmetrical there.

> It might be that you are only actually running at USB2 speeds
> (check with lsusb -t).
> 
> I have seem line rate Ge from my ax88179 card, but only with a
> patched kernel.

David, did you mean you have the same line rate as Daniel?

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
