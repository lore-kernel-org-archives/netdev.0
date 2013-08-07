From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v3 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Wed, 7 Aug 2013 08:41:51 +0800
Message-ID: <CACVXFVOOQZ8mtDXtCE669vEo=jA56g-ADzTZkGLLupZ5D4Z==A@mail.gmail.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	<1375750370-18194-5-git-send-email-ming.lei@canonical.com>
	<1375791737.4457.98.camel@edumazet-glaptop>
	<CANEJEGvbS=o-942tFJTDzpNvgaB=KUZcBwzJCU-7OHaAF-aQFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45920 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586Ab3HGAly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 20:41:54 -0400
In-Reply-To: <CANEJEGvbS=o-942tFJTDzpNvgaB=KUZcBwzJCU-7OHaAF-aQFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 7, 2013 at 1:09 AM, Grant Grundler <grundler@google.com> wrote:
> On Tue, Aug 6, 2013 at 5:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> ...
>>> @@ -1310,6 +1318,10 @@ static int ax88179_reset(struct usbnet *dev)
>>>
>>>       dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>>>                                NETIF_F_RXCSUM;
>>> +     if (dev->can_dma_sg) {
>>> +             dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
>>> +             dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
>>> +     }
>>>
>>
>> My concern with setting TSO on reset() is the following :
>>
>> Admin can disable TSO with
>>
>> ethtool -K ethX tso off
>>
>>
>> Then, one hour later, or one month later, a reset happens, and this code
>> magically re-enables TSO
>>
>> So, I really think this part should be removed from your patch.
>
> Following that logic, shouldn't all the features/hw_features settings
> be removed from reset code path?

This patch won't touch other settings because that isn't related with
this patch.

>
> hw_features shouldn't change since power up.
> FWIW, I do agree with you.
>
> I'll note that any "hiccup" in the USB side that causes the device to
> get dropped and re-probed will cause the same symptom. There is

I am afraid that PCI network devices' setting still won't survive unbound&
re-probed, will they?

> nothing the driver can do about it in this case. Perhaps add some udev
> rules to preserve ethtool settings the same way I've seen udev rules
> to record MAC address to enumerate devices (eth0, eth1, etc.)

Some usbnet devices may have random MAC address assigned in every
probe().


Thanks,
--
Ming Lei
