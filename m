From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] usbnet: increase URB reference count before
 usb_unlink_urb
Date: Thu, 22 Mar 2012 19:33:36 -0400 (EDT)
Message-ID: <20120322.193336.57225513335096988.davem@davemloft.net>
References: <1332422538-6597-1-git-send-email-tom.leiming@gmail.com>
	<20120322143553.GC19835@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120322143553.GC19835-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Date: Thu, 22 Mar 2012 07:35:53 -0700

> On Thu, Mar 22, 2012 at 09:22:18PM +0800, Ming Lei wrote:
>> Commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d(net/usbnet: avoid
>> recursive locking in usbnet_stop()) fixes the recursive locking
>> problem by releasing the skb queue lock, but it makes usb_unlink_urb
>> racing with defer_bh, and the URB to being unlinked may be freed before
>> or during calling usb_unlink_urb, so use-after-free problem may be
>> triggerd inside usb_unlink_urb.
>> 
>> The patch fixes the use-after-free problem by increasing URB
>> reference count with skb queue lock held before calling
>> usb_unlink_urb, so the URB won't be freed until return from
>> usb_unlink_urb.
>> 
>> Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
>> Cc: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
>> Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
>> Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
>> Reported-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
