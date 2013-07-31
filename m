From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports sg dma
Date: Wed, 31 Jul 2013 23:25:13 +0800
Message-ID: <CACVXFVOmpRYaqt5qm+txc7fOEFzq9TDRUGQc-+D-bFct-=fCHw@mail.gmail.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	<1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	<20130731124707.GA30635@kroah.com>
	<CACVXFVNk+h7kBWTFT2NiGy+2F6LPatda3oL9+uuaQnT-u5J8wg@mail.gmail.com>
	<1375279366.14846.1.camel@linux-fkkt.site>
	<1375283711.10515.104.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34476 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760266Ab3GaPZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:25:16 -0400
In-Reply-To: <1375283711.10515.104.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 11:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-07-31 at 16:02 +0200, Oliver Neukum wrote:
>> On Wed, 2013-07-31 at 21:50 +0800, Ming Lei wrote:
>>
>> > In the usbnet case, the driver already supports non-sg well. Actually,
>> > all current drivers should support non-sg well because urb->sg wasn't
>> > introduced for very long time. We can think it as a new feature or DMA
>> > enhancement for xHCI controller.
>> >
>> > If you mean buffer debounce for dma sg support on ehci/uhci/ohci/..,
>> > maybe we need to discuss and evaluate further.
>>
>> We cannot lie to the networking layer. Either we can do sg in hardware
>> or we cannot. This is unfortunately determined by the HC not the device
>> on the bus. How else but from the host driver would we get the
>> information?
>>
>
> Hmm, I would rather make sure SG is really supported before adding TSO
> support.
>
> TCP stack can build skb with fragments of any size, not multiple
> of 512 or 1024 bytes.

For this SG buffer, only xHCI USB host controller supports it, and other
host controllers can't support it if they don't use bounce buffer, but usbnet
devices may be connected to all these host controllers.

This patchset only enables SG/TSO support when ax88179_178a device
connects to xHCI host controller.

Thanks,
--
Ming Lei
