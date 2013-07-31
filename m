From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 0/4] USB & USBNET: loose DMA SG check and support usbnet
 DMA SG
Date: Wed, 31 Jul 2013 19:55:15 +0800
Message-ID: <CACVXFVOsympDWLkGHZqzL4jOcxTLS662a18gsix9ZtZNr4tDQA@mail.gmail.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	<1375269128.17175.8.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33113 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755596Ab3GaLzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 07:55:18 -0400
In-Reply-To: <1375269128.17175.8.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 7:12 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Wed, 2013-07-31 at 18:51 +0800, Ming Lei wrote:
>> Hi,
>>
>> This patchset allows drivers to pass sg buffers which size can't be divided
>> by max packet size of endpoint if the host controllers support this kind
>> of sg buffers.
>
> Cool. One question though. It makes sense to use sg only
> if all elements are in memory capable of DMA. It seems to be possible
> to have HCs which can do unlimited sg but are limited to 32bit DMA.

For current usbnet devices which supports TSO, one header need to add
before skb->data from network stack, so basically the first two elements aren't
OK for other HCs(EHCI/UHCI/...) to DMA from SG.


Thanks,
--
Ming Le
