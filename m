From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 22:04:54 +0200
Message-ID: <200608232204.54396.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B5D2@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:19408
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965183AbWHWUFZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 16:05:25 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B5D2@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 21:54, Simon Barber wrote:
> I'd agree the memory benefit is not worth the work and complexity. The
> additional benefit is tighter queue control - reducing the latency
> between the software qdisc (and whatever scheduling/rate controlling/etc
> work they are doing) and the frames coming out of the hardware. A 100
> frame DMA queue can be 1.2 seconds of transmit time, or it can be 30ms
> of transmit time depending on frame size and transmission rate. This
> disparity will only get larger as rates go up with 11n.
> 
> A further benefit in reducing this latency - is to keep the latency
> between the software rate control algorithm (which sees frames before
> they hit the DMA queue) and the hardware tx down. This allows the
> software rate control to be more responsive.

Hm, I don't really see how a larger DMA ring adds latency.
A DMA ring is endless. From the device and driver point
of view it only goes forward. If we reach the physical end
while going forward, we simply start at the beginning again.
Both, device and driver maintain very simple pointers into the
ring that are simply incremented.

TX notification latency is only controlled by a flag in the
descriptor control. We currently request an IRQ for each frame,
so latency is as low as possible here.

Maybe I don't understand what you are trying to explain, but I
don't see a benefit other than lower memory usage by reducing
DMA ring length.

-- 
Greetings Michael.
