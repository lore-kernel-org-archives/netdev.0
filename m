From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Stop using tasklets for bottom halves
Date: Tue, 8 Sep 2009 06:50:41 +0200
Message-ID: <200909080650.43181.mb@bu3sch.de>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com> <20090907171406.6a4b6116@nehalam> <1252376254.21261.2052.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt Smith <Matt.Smith-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Kevin Hayes <kevin-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar-NvJAj8134tRxEa0u/P/EHDe48wsgrGvP@public.gmane.org>, ic.felix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1252376254.21261.2052.camel-f9ZlEuEWxVcI6MkJdU+c8EEOCMrvLtNR@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 September 2009 04:17:34 Steven Rostedt wrote:
> > Process context is too slow.
> 
> Well, I'm hoping to prove the opposite. I'm working on some stuff that I
> plan to present at Linux Plumbers. I've been too distracted by other
> things, but hopefully I'll have some good numbers to present by then.

I recently converted the b43 driver to threaded interrupt handlers and
a workqueue based TX mechanism. (My motivation was porting b43 to the SDIO bus that
needs to sleep, so requires process context).

There are two things that I noticed. When looking at the "idle" percentage in "top"
it regressed quite a bit when using threaded IRQ handlers. It shows about 8% less
idle. This is with threaded IRQs patched in, but without WQ TX mechanism. Applying
the WQ TX mechanism does not show any noticeable effect in "top".

I'm not quite sure where the 8% slowdown on threaded IRQ handlers come from. I'm not
really certain that it's _really_ a regression and not just a statistics accounting quirk.
Why does threaded IRQs slow down stuff and threaded TX does not at all? That does not
make sense at all to me.

I think there's no real reason for process context being slow in general. It's just that
we have additional context switches. But these are fast on Linux.

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
