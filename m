From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Wed, 19 Mar 2014 17:58:41 -0700
Message-ID: <CANEJEGtZF30=bqkErvi1CFZLbk=PJ-p_gKf9eBGU7sWwJcrefg@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	<CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	<1395093343.3961.2.camel@linux-fkkt.site>
	<CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
	<CAODwPW-E-3HcXCGEmp9JpW6hU-Xt-FHwBtqeSSTDGaRPqO49Sw@mail.gmail.com>
	<CANEJEGscbVF3gRLNtTAcRSpHGVm1iDDKEeBscXcwj2-YdkiDXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Julius Werner <jwerner-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANEJEGscbVF3gRLNtTAcRSpHGVm1iDDKEeBscXcwj2-YdkiDXA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 18, 2014 at 6:40 PM, Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Mar 18, 2014 at 6:09 PM, Julius Werner <jwerner-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>> I think a better place for this would be in usbnet_probe() (together
>> with all the other dev->xxx initialization).
>
> Definitely better.
>
> @@ -1536,6 +1536,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb
>         dev->driver_name = name;
>         dev->msg_enable = netif_msg_init (msg_level, NETIF_MSG_DRV
>                                 | NETIF_MSG_PROBE | NETIF_MSG_LINK);
> +       init_waitqueue_head(&dev->wait);
>         skb_queue_head_init (&dev->rxq);
>         skb_queue_head_init (&dev->txq);
>         skb_queue_head_init (&dev->done);

Oliver,
So even with this additional change to usbnet_probe, the device is
reporting a link but can't transmit packets.
I've tried with three different USB dongles (AX88178, AX88772B, SMSC75xx).

In the last case, I ran "ifconfig eth0 192.168.1.100" and then tried
to ping 192.168.1.1. "ifconfig eth0" then reports "RX packets 0 bytes
0" and "TX packets 0 bytes 10796". The TX packets != bytes seems odd
and suggests (to me) that data getting discarded someplace in the
stack. I confirmed by running tcpdump on the other end of the link
(192.168.1.1 side) and got nothing from 192.168.1.100.

I believe the "10796" TX bytes is due to the connection manager
"trying really hard" to get an IP address (via DHCP).

Your patch looks like it should work. But it's missing something and I
don't have a clue what it is. Ideas?

cheers,
grant
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
