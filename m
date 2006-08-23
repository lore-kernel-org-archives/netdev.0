From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 13:10:05 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B5DC@dhost002-46.dex002.intermedia.net>
References: <200608232204.54396.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jiri Benc" <jbenc@suse.cz>, <linville@tuxdriver.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:24484 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965166AbWHWUJw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 16:09:52 -0400
Content-class: urn:content-classes:message
in-reply-to: <200608232204.54396.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DMA ring forms a queue of frames. Frames live in that queue for some
time before they are transmitted. This is a source of latency between
the software process that puts  the frames in the queue and the point in
time when they are actually transmitted.

Simon


-----Original Message-----
From: Michael Buesch [mailto:mb@bu3sch.de] 
Sent: Wednesday, August 23, 2006 1:05 PM
To: Simon Barber
Cc: Jiri Benc; linville@tuxdriver.com; netdev@vger.kernel.org
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()

On Wednesday 23 August 2006 21:54, Simon Barber wrote:
> I'd agree the memory benefit is not worth the work and complexity. The

> additional benefit is tighter queue control - reducing the latency 
> between the software qdisc (and whatever scheduling/rate 
> controlling/etc work they are doing) and the frames coming out of the 
> hardware. A 100 frame DMA queue can be 1.2 seconds of transmit time, 
> or it can be 30ms of transmit time depending on frame size and 
> transmission rate. This disparity will only get larger as rates go up
with 11n.
> 
> A further benefit in reducing this latency - is to keep the latency 
> between the software rate control algorithm (which sees frames before 
> they hit the DMA queue) and the hardware tx down. This allows the 
> software rate control to be more responsive.

Hm, I don't really see how a larger DMA ring adds latency.
A DMA ring is endless. From the device and driver point of view it only
goes forward. If we reach the physical end while going forward, we
simply start at the beginning again.
Both, device and driver maintain very simple pointers into the ring that
are simply incremented.

TX notification latency is only controlled by a flag in the descriptor
control. We currently request an IRQ for each frame, so latency is as
low as possible here.

Maybe I don't understand what you are trying to explain, but I don't see
a benefit other than lower memory usage by reducing DMA ring length.

--
Greetings Michael.
