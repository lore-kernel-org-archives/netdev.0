From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 21:45:05 +0200
Message-ID: <200608232145.05763.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B5C6@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39365
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965164AbWHWTp0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 15:45:26 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B5C6@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 21:30, Simon Barber wrote:
> One question - in most hardware implementations today the queues are DMA
> rings. In this case the right length of the queue is determined by the
> interrupt/tx_softirq latency required to keep the queue from becoming
> empty. With 802.11 there are large differences in the time it takes to
> transmit different frames - a full size 1Mbit frame vs. a short 54Mbit
> frame. Would it be worth optimizing the DMA queue length to be a
> function of the amount of time rather than number of frames?

I doubt that the added complexity would do any good.
We should look at what a ring actually is.
A ring is an allocated memory space with dma descriptors in it.
The ring size if the number of dma descriptors. So theoretically
the number of descriptors adds up to the size to allocate.
In practice we have alignment issues (at least for bcm43xx).
For a ring we always allocate one page of memory. Regardless
of how much of it is actually used by descriptors.
One wireless-specific thing remains, though. We store meta
data for each descriptor (The ieee80211_tx_control at least).
So basically only the memory consumption of the meta data
could be optimized.

We used to have 512 TX descriptors for each ring until I recently
submitted a patch to lower it to 128. I did this because after
doing stress tests the maximum amount of used descriptors did
not go over about 80 on my machines.

I think it basically comes down to the question:
Do we want to save 1 kb of memory[*] but pay the price of
additional code complexity?

[*] 1kb is a random value invented by me. I did not calculate
    it, but it should be somewhere around that value.

-- 
Greetings Michael.
