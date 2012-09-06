From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Thu, 06 Sep 2012 11:11:37 +0200
Message-ID: <1346922697.2484.5.camel@edumazet-glaptop>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	 <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
	 <6556435.5o3fR8ZcBa@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	"bjorn-yOkvZcmFvRU@public.gmane.org" <bjorn-yOkvZcmFvRU@public.gmane.org>, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6556435.5o3fR8ZcBa-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-06 at 10:50 +0200, Oliver Neukum wrote: 
> On Thursday 06 September 2012 10:13:01 Alexey ORISHKO wrote:

> > Rx path:
> > 4. IP packets are cloned to separate skb and length of actual data
> set to eth packet size, while skb size is still the same as skb
> containing full NTB frame. This causes problems with TCP stack when
> throughput is high because of flow control in the stack, if too much
> data allocated.
> > Someone suggested a patch for it, which was rejected. Anyway, I
> don't think copy data to a new skb would be a nice solution, but
> keeping several clones with size equal to incoming skb in not good
> either. 
> 
> Perhaps the problem is using an skb for aggregate reception at all.
> Possibly enough buffers of fixed size should be allocated on open and
> reused,
> not freed.

Really skb_clone() use should be removed from cdc_ncm_rx_fixup()

Unless you expect 10Gbit speed from this driver, skb_clone() is the
worst possible strategy.

Allocating fresh skbs of the right size permits better memory use and
allows TCP coalescing as well.

The use of skb_clone() forces some parts of the stack to perform a full
copy anyway.

It's still unclear to me with we use up to 32KB blocks in USB drivers...


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
