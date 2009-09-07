From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Stop using tasklets for bottom halves
Date: Mon, 7 Sep 2009 15:58:50 -0700
Message-ID: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt Smith <Matt.Smith-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Kevin Hayes <kevin-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar-NvJAj8134tRxEa0u/P/EHDe48wsgrGvP@public.gmane.org>, ic.felix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A while ago I had read about an effort to consider removing tasklets
[1] or at least trying to not use them. I'm unaware of the progress in
this respect but since reading that article have always tried to
evaluate whether or not we need tasklets on wireless drivers. I have
also wondered whether work in irq context in other parts of the kernel
can be moved to process context, a curious example being timers. I'll
personally be trying to using only process context on bottom halves on
future drivers but I figured it may be a good time to ask how serious
was avoiding tasklets or using wrappers in the future to avoid irq
context is or is it advised. Do we have a general agreement this is a
good step forward to take? Has anyone made tests or changes on a
specific driver from irq context to process context and proven there
are no significant advantages of using irq context where you would
have expected it?

Wireless in particular should IMHO not require taskets for anything
time sensitive that I can think about except perhaps changing channels
quickly and to do that appropriately also process pending RX frames
prior to a switch. It remains to be seen experimentally whether or not
using a workqueue for RX processing would affect the time to switch
channels negatively but I doubt it would be significant. I hope to
test that with ath9k_htc.

What about gigabit or 10 Gigabit Ethernet drivers ? Do they face any
challenges which would yet need to be proven would not face issues
when processing bottom halves in process context?

[1] http://lwn.net/Articles/239633/

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
