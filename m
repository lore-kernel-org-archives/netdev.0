From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: Fwd: usbnet: Recursive Locking bug ?
Date: Tue, 7 Dec 2010 20:55:50 -0800 (PST)
Message-ID: <917120.68161.qm@web180301.mail.gq1.yahoo.com>
References: <AANLkTi=VB0Kt=2c1C1b-Ps8x_zA5Tnf+tfHjvO8gWgm8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi=VB0Kt=2c1C1b-Ps8x_zA5Tnf+tfHjvO8gWgm8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I'll look at this some later, though I seem to
have missed a post with the diagnostic saying
what lock is being recursed.

That particular chunk of code has periodically
turned up problems, and isn't very pretty.  But
the most curious aspect of it is that it seemed
to shake out HCD-specific behaviors.  (We've
gotten rid of most such code by now, this is a
slight exception.

Specifically, HCDs that could unlink speedily
without certain locking patterns (ISTR OHCI and
EHCI, if not also UHCI) didn't trigger oddness.
But some other HCDs, with different approaches
to unlinking URBs, were less happy.  ( I was
likely working with MUSB at the time.)

I spent some time trying to rework that code in
"usbnet", but no clean-and-obvious solutions
became apparent when I did that (a few years
back).  Plus, ISTR being the only person to
find issues (back then), so I couldn't make
an argument to spend much more time on it.

Hope that helps anyone trying to fix this.

- Dave


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
