From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: changing usbnet's API to better deal with cdc-ncm
Date: Mon, 10 Sep 2012 19:10:19 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AAB5822@EXDCVYMBSTM006.EQ1STM.local>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
 <1800340.RWjbMaZGSN@linux-lqwf.site>
 <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5753D@EXDCVYMBSTM006.EQ1STM.local>
 <1609320.M17H7UceTZ@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1609320.M17H7UceTZ-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Oliver Neukum [mailto:oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org]
> Sent: Friday, September 07, 2012 8:23 PM
> 
> > There is a temptation to send full NTBs even with a single IP packet,
> > But it will lead to wasted USB bandwidth and reduced ability to send
> > real data for other functions in the device or other devices on the
> > same root hub. Most important it will also harm IN direction.
> 
> Well, we will eventually need to do so. In that case, shall we send a
> short package or not?

The trick is to find a compromise for device load vs wasted bandwidth. 
Currently if data size is less than 512 bytes, a shot packet will be sent. 
However, this value might be better tuned based on bus speed (HS/SS)
and max NTB size negotiated.

Note, that ZLP was avoided in the ncm driver by using flag in usbnet,
because on some embedded USB controllers handling ZLP was more costly
than short packet.

> Well, we know how many packages are available to the device because
> they have already been scheduled. It seems to be clear that we need to
> batch while enough are on the way.

It doesn't matter much that some packets on the way to device. What
matters is the amount of packets in the application Tx queue for
ncm network device.

> > But an optimal implementation requires that the amount of IP packets
> > "in progress" or queued up is known to NCM so NCM can decide to send
> > short or padded NTB or aggregate and send one or more full NTBs plus
> > short or padded NTB.
> 
> What exactly means "in progress"?

Sent by application to the network device.

> 
> > An implementation where NCM only knows if there is more data
> available
> > or not can be shown to have side-effects that are not easily
> circumvented.
> > And likewise shown to limit throughput compared to a timer-based
> solution.
> 
> Well, I must say that the timer is ugly. If absolutely necessary we can
> keep it, but then I'd much prefer to put it into usbnet and have a
> generic batching functionality. However, I'd like to explore
> aternatives.

Is it possible to implement upper layer Tx queue in usbnet, so mini driver 
could get a clue about outstanding packets to be transmitted?

Regards,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
