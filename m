From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: net: usb: cdc_ncm: add support IFF_NOARP
Date: Tue, 8 Jan 2013 23:24:06 +0100
Message-ID: <CAL_Kpj1_UxJOtXmA4fJO8T2eUzba5LdcSJ0=N2HdFCnn2kk_+w@mail.gmail.com>
References: <001601cdeda2$2547a6b0$6fd6f410$@com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Hans Petter Selasky <hans.petter.selasky-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <001601cdeda2$2547a6b0$6fd6f410$@com>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Jan 8, 2013 at 2:14 PM, Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi Alexey,
>         Recently I met a Modem which cannot do ARP. But I found our
> cdc_ncm_bind() function cannot handle this special case. Do you have any
> plan to handle it?
>
>
> static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
> {
>         ...
>         /*  cannot do ARP */
>         dev->net->flags |= IFF_NOARP;
>         ...
> }

All devices I have can handle ARP, so there was no need for such a
feature in the driver..

Last version of the driver also supports MBIM devices, which have no
MAC address at all
since payload is a pure IP, While considering changes this shall be
taken into account.

There is no way to find out if ARP is supported or not by looking at
CDC Ethernet
Networking or NCM Functional Descriptors. If control that flag to be
added to the driver,
it shall be based on matching VID/PID.

Regards,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
