From: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
 synchronization, v5
Date: Mon, 4 May 2009 07:45:22 -0700
Message-ID: <20090504074522.13f1ed77@infradead.org>
References: <20090503162115.2dff79bd@infradead.org>
	<Pine.LNX.4.44L0.0905041026560.2961-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
	David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	<linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.0905041026560.2961-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 4 May 2009 10:30:06 -0400 (EDT)
Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org> wrote:

> On Sun, 3 May 2009, Arjan van de Ven wrote:
> 
> > > Perhaps with some enterprise systems, it is preferred to have the 
> > > system fail with an explicit error message rather than wait 
> > > indefinitely...
> > 
> > actually, in an enterprise system, you want to reboot.
> > The bootloader might boot a different kernel the next time
> > that is known to work.
> > (for example, the current kernel might have been booted with the
> > "once" grub option)
> 
> Which makes it imperative that the system knows when all the block
> devices have been probed, so it can stop waiting.
> 
> > > How does Arjan's async boot system tell use when all discovery is
> > > complete?  AFAICS, it only tells you when all its async tasks are
> > > finished.  But device discovery and registration sometimes use
> > > other asynchronous techniques which Arjan's code is unaware of.
> > > Examples: the USB khubd thread, the USB mass-storage scanning
> > > thread, and the SCSI async-scanning thread.
> > 
> > for normal device probing we already have infrastructure though...
> > wait_for_device_probe, driver_probe_done and friends...
> > (the scsi scanning thread is being converted to the async
> > infrastructure btw)
> > 
> > do we need to invent more ?
> 
> I suppose the usb-storage scanning thread could also be converted to 
> the async infrastructure, although I haven't heard of anybody working 
> on it.
> 
> But the USB hub driver's thread (khubd) cannot be converted.  It is 
> central to the discovery of USB-based block devices.  How would you 
> handle that?

take a ref in the driver_probe_done() sense, and release it when you
know you're done probing....

at that point all existing infrastructure will just work.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
