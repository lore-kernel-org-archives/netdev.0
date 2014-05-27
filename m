From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: skbuff truesize incorrect.
Date: Tue, 27 May 2014 11:52:43 -0400 (EDT)
Message-ID: <20140527.115243.2071632723301616912.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
	<20140523.161823.1006372695373018122.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D1724E565@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamal-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mszeredi-AlSwsSmVLrQ@public.gmane.org,
	fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org
To: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724E565-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Date: Tue, 27 May 2014 15:23:14 +0000

> True, you still need to sort out how to handle multiple ethernet
> frames in the same 4k page, and arbitrary page boundaries within a
> frame.

Multiple ethernet frames in the same 4K page is used by several ethernet
drivers already.  NIU for one.

Several chips have various pools of pages, chopped up into different
power-of-2 chunks.

As the packet arrives, they build up the packet using buffers from the
different sized pools.

Anyways, you just have to charge the page to all packets contained
within.  This doesn't seem to be much of an issue to address.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
