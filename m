From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
 synchronization, v5
Date: Sat, 2 May 2009 13:55:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0905021335150.26241-100000@netrider.rowland.org>
References: <1241272876.3639.27.camel@mulgrave.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1241272876.3639.27.camel-0iu6Cu4xQGLV0bN/WMK0Sm4KqUE0Tg80jeSHHoATDr/QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2 May 2009, James Bottomley wrote:

> OK, so in your scheme, I get why console devices: they need to be
> present early before we start dumping console output otherwise it can
> get lost.
> 
> However, I don't see the need for either network or block.
> 
> For network, the only early discovery use is net root (which can be done
> fully asynchronously)

Are you referring to the "rootwait" kernel parameter?  Is there a 
reason why this is a boot-time parameter instead of always being set?  
I mean, under what circumstances would you _not_ want to wait until the 
root device is present?

>  or net console (which I think can be supplied a
> raft of information and isn't usually expected to be up by early boot
> because of the TCP stack dependence) neither of which is a compelling
> use case.

Are you sure the real reason it isn't expected to be up isn't the lack
of a mechanism of the type being proposed?

> Block, likewise, is a udev type discovery:  We can specify the root by
> some type of ID and we can wait until that is found, rather than have an
> elaborate system to check when discovery is finished, which is the only
> benefit this code seems to provide.

The real benefit of knowing when discovery is complete is that it tells
you when to give up and stop waiting.  However I have to agree that in
the case of the root device, there really isn't much point in giving
up.

Perhaps with some enterprise systems, it is preferred to have the 
system fail with an explicit error message rather than wait 
indefinitely...

> What I'm getting at is that I don't see the benefit of this in the light
> of Arjan's async boot system, which can also tell us when all discovery
> is complete ... what added benefit am I missing here?

How does Arjan's async boot system tell use when all discovery is
complete?  AFAICS, it only tells you when all its async tasks are
finished.  But device discovery and registration sometimes use other
asynchronous techniques which Arjan's code is unaware of.  Examples:  
the USB khubd thread, the USB mass-storage scanning thread, and the
SCSI async-scanning thread.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
