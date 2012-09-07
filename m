From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 07 Sep 2012 20:23:17 +0200
Message-ID: <1609320.M17H7UceTZ@linux-lqwf.site>
References: <2791550.LhGu6po6Xy@linux-lqwf.site> <1800340.RWjbMaZGSN@linux-lqwf.site> <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5753D@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5753D-8ZTw5gFVCTjVH5byLeRTJxkTb7+GphCuwzqs5ZKRSiY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 07 September 2012 17:23:33 Alexey ORISHKO wrote:

> There is a temptation to send full NTBs even with a single IP packet,
> But it will lead to wasted USB bandwidth and reduced ability to send
> real data for other functions in the device or other devices on the
> same root hub. Most important it will also harm IN direction.

Well, we will eventually need to do so. In that case, shall we send a short package
or not?

> The challenge is to ensure that an acceptable timeout value is used. Too
> long and latency is introduced. Too short and too many padded NTBs will
> go out and that reduces the available throughput. The ideal timer value
> depends on the throughput available in the network. Something that is not
> really explicitly known to the NCM layer nor to the layer above.

Well, we know how many packages are available to the device because
they have already been scheduled. It seems to be clear that we need to
batch while enough are on the way.

> Alternate methods exist to achieve the same result without using a timer.
> But an optimal implementation requires that the amount of IP packets "in
> progress" or queued up is known to NCM so NCM can decide to send short or
> padded NTB or aggregate and send one or more full NTBs plus short or
> padded NTB.

What exactly means "in progress"?

> An implementation where NCM only knows if there is more data available or
> not can be shown to have side-effects that are not easily circumvented.
> And likewise shown to limit throughput compared to a timer-based solution.   

Well, I must say that the timer is ugly. If absolutely necessary we can keep
it, but then I'd much prefer to put it into usbnet and have a generic batching
functionality. However, I'd like to explore aternatives.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
