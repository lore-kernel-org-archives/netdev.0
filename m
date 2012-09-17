From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC PATCH 0/3] usbnet: support runtime PM triggered by link change
Date: Mon, 17 Sep 2012 16:25:59 +0800
Message-ID: <CACVXFVONb+pKkydhp3iesLt0tKvc+56uv6sd5S0UwUnGZiowYA@mail.gmail.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
	<2236952.YSZj5xxzHO@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Fink Dmitry <finik-l0cyMroinI0@public.gmane.org>, Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2236952.YSZj5xxzHO-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 17, 2012 at 4:04 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> On Sunday 16 September 2012 01:48:16 Ming Lei wrote:
>
> Hi,
>
>> Currently only very few usbnet devices support the traffic based
>> runtime PM, eg. wake up devices if there are packets to be transmitted.
>>
>> For the below situation, it should make sense to runtime suspend usbnet
>> device to save power:
>>
>>         - after network link becomes down
>
> Basically cool design, but it raises two fundamental questions
> and some detail questions.
>
>> This patch implements the runtime PM triggered by network link change
>> event, and it works basically on asix usbnet device after a simple
>> runtime PM test.
>
> 1) Does it actually save power? You are constantly waking up a CPU.

Of course, it does. I don't know it will save how much power just on
usbnet device, but it may save power from usb hub and usb host
controller in the bus at least.

Anyway we don't need to waste power if the link of usbnet is down.

It just wake up CPU one time each 3sec. In modern linux distribution,
the CPU will be wakup tens times per second, so it shouldn't be a
big problem.

> From that perspective it is possible that leaving on the ethernet is actually
> better in terms of power. Only measurements can answer that question.

You know it is a bit difficult to test power save for this situation. And
most of runtime PM patches didn't provide power save data. In fact,
I'd like to do it, but I have not some equipment to measure it, :-(.

>
> 2) Do we have many devices that would be serviced with this approach?

At least I found asix can be serviced by this approach. Considered asix
is quite popular, it is worthy of the effort. Also the below devices can be
serviced by the patch in theory:

                   dm9601.c / mcs7830.c / sierra_net.c

In fact, it might be used by other non-usbnet devices too.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
