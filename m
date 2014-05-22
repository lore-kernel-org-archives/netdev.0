From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 13:30:03 -0700
Message-ID: <1400790603.5367.167.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com>
	 <20140522.152146.2116142050088142989.davem@davemloft.net>
	 <537E5C63.7080607@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kamal-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mszeredi-AlSwsSmVLrQ@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org
To: Jim Baxter <jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <537E5C63.7080607-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-05-22 at 21:21 +0100, Jim Baxter wrote:


> OK, so it is the value of the memory that has been allocated for the SKB.
> If there are multiple clones for an skb all pointing at the same data,
> will that distort the memory used when they all have the same truesize?

Its always better to over estimate memory uses, than under estimating.

Its all about guarding against OOM.

Keep in mind some parts of networking stack do not like clones.

TCP coalescing works beautifully with non cloned skbs.

Instead of cloning skb or doing copies, you could play with having frame
on a page fragment. Only headers might need to be pulled from the frame
to linear part of skb.





--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
