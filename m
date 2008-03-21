From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Fri, 21 Mar 2008 21:16:48 +0100
Message-ID: <200803212116.49462.mb@bu3sch.de>
References: <Pine.LNX.4.44L0.0803202126240.11234-100000@netrider.rowland.org> <20080321165405.GC5766@kroah.com> <20080321125950.a5b38bda.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org, david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org,
	rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org, lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080321125950.a5b38bda.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 21 March 2008 20:59:50 Andrew Morton wrote:
> They could of course be switched to using
> kmalloc(GFP_ATOMIC)+memcpy()+schedule_task().  That's rather slow, but this
> is not a performance-sensitive area.  But more seriously, this could lead
> to messages getting lost from a dying machine.

Well, IMO drivers that need to sleep to transmit some data (to whatever,
the screen or something) are not useful for debugging a crashing kernel anyway.
Or how high is the possibility that it'd survive the actual sleep in the
memory allocation? I'd say almost zero.
So that schedule_task() is not that bad.

-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
