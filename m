From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3/3] usbnet: fix skb traversing races during unlink(v1)
Date: Tue, 15 May 2012 13:42:30 -0400 (EDT)
Message-ID: <20120515.134230.1049511425953862050.davem@davemloft.net>
References: <1335775864-4873-4-git-send-email-tom.leiming@gmail.com>
	<20120502.201212.909292764269133334.davem@davemloft.net>
	<20120503090450.41704527@tom-ThinkPad-T410>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120503090450.41704527@tom-ThinkPad-T410>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 3 May 2012 09:04:50 +0800

>>From a87ff961f0a5d50223bd084dfac4fe5ce84f3913 Mon Sep 17 00:00:00 2001
> From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 26 Apr 2012 11:33:46 +0800
> Subject: [PATCH] usbnet: fix skb traversing races during unlink(v2)
> 
> Commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d(net/usbnet: avoid
> recursive locking in usbnet_stop()) fixes the recursive locking
> problem by releasing the skb queue lock before unlink, but may
> cause skb traversing races:
> 	- after URB is unlinked and the queue lock is released,
> 	the refered skb and skb->next may be moved to done queue,
> 	even be released
> 	- in skb_queue_walk_safe, the next skb is still obtained
> 	by next pointer of the last skb
> 	- so maybe trigger oops or other problems
> 
> This patch extends the usage of entry->state to describe 'start_unlink'
> state, so always holding the queue(rx/tx) lock to change the state if
> the referd skb is in rx or tx queue because we need to know if the
> refered urb has been started unlinking in unlink_urbs.
> 
> The other part of this patch is based on Huajun's patch:
> always traverse from head of the tx/rx queue to get skb which is
> to be unlinked but not been started unlinking.
> 
> Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
