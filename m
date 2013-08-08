From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Thu, 8 Aug 2013 10:25:37 -0700
Message-ID: <CANEJEGvvxi83=b+NGTzsVpJw5fE5nb-R0BRWRJ2gz7bF5-H5AA@mail.gmail.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	<1375750370-18194-5-git-send-email-ming.lei@canonical.com>
	<1375791737.4457.98.camel@edumazet-glaptop>
	<CANEJEGvbS=o-942tFJTDzpNvgaB=KUZcBwzJCU-7OHaAF-aQFQ@mail.gmail.com>
	<CACVXFVOOQZ8mtDXtCE669vEo=jA56g-ADzTZkGLLupZ5D4Z==A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVOOQZ8mtDXtCE669vEo=jA56g-ADzTZkGLLupZ5D4Z==A@mail.gmail.com>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 6, 2013 at 5:41 PM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> On Wed, Aug 7, 2013 at 1:09 AM, Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
...
>> Following that logic, shouldn't all the features/hw_features settings
>> be removed from reset code path?
>
> This patch won't touch other settings because that isn't related with
> this patch.

Sorry - I didn't mean to imply your patch should do this. I was hoping
for a yes/no answer from you, Eric, or Dave.

...
>> I'll note that any "hiccup" in the USB side that causes the device to
>> get dropped and re-probed will cause the same symptom. There is
>
> I am afraid that PCI network devices' setting still won't survive unbound&
> re-probed, will they?

Correct - but PCI isn't as prone to "dropping off the bus" like USB
is. Master aborts on some PCI systems is a "Fatal Exception" and AFAIK
that's never been true for any USB device.

>> nothing the driver can do about it in this case. Perhaps add some udev
>> rules to preserve ethtool settings the same way I've seen udev rules
>> to record MAC address to enumerate devices (eth0, eth1, etc.)
>
> Some usbnet devices may have random MAC address assigned in every
> probe().

Ugh - ok. Then those scripts are broken for those devices. C'est la Vie.

My point is the mechanism (udev) exists to preserve any settings
ethtool can read/record the state of.

cheers,
grant

ps. thanks again for posting the USBNET sg dma series - I will likely
back port those to our chromeos-3.8 tree in the near future.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
