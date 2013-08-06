From: Grant Grundler <grundler@google.com>
Subject: Re: [PATCH v3 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Tue, 6 Aug 2013 10:09:34 -0700
Message-ID: <CANEJEGvbS=o-942tFJTDzpNvgaB=KUZcBwzJCU-7OHaAF-aQFQ@mail.gmail.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	<1375750370-18194-5-git-send-email-ming.lei@canonical.com>
	<1375791737.4457.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:42383 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756272Ab3HFRJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 13:09:34 -0400
Received: by mail-oa0-f47.google.com with SMTP id g12so1290229oah.34
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 10:09:34 -0700 (PDT)
In-Reply-To: <1375791737.4457.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 6, 2013 at 5:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
...
>> @@ -1310,6 +1318,10 @@ static int ax88179_reset(struct usbnet *dev)
>>
>>       dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>>                                NETIF_F_RXCSUM;
>> +     if (dev->can_dma_sg) {
>> +             dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
>> +             dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
>> +     }
>>
>
> My concern with setting TSO on reset() is the following :
>
> Admin can disable TSO with
>
> ethtool -K ethX tso off
>
>
> Then, one hour later, or one month later, a reset happens, and this code
> magically re-enables TSO
>
> So, I really think this part should be removed from your patch.

Following that logic, shouldn't all the features/hw_features settings
be removed from reset code path?

hw_features shouldn't change since power up.

FWIW, I do agree with you.

I'll note that any "hiccup" in the USB side that causes the device to
get dropped and re-probed will cause the same symptom. There is
nothing the driver can do about it in this case. Perhaps add some udev
rules to preserve ethtool settings the same way I've seen udev rules
to record MAC address to enumerate devices (eth0, eth1, etc.)

cheers,
grant
