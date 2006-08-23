From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 13:32:22 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B5E4@dhost002-46.dex002.intermedia.net>
References: <200608232220.07093.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jiri Benc" <jbenc@suse.cz>, <linville@tuxdriver.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:58792 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965173AbWHWUcJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 16:32:09 -0400
Content-class: urn:content-classes:message
in-reply-to: <200608232220.07093.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Right - and what I'm proposing is that we don't just count the number of
frames in the ring - but also count the amount of frame time the ring
takes too. This way if there are a number of large, slow frames we can
stop adding more frames into the ring well before we reach the limit on
the number of frames. 

Simon

-----Original Message-----
From: Michael Buesch [mailto:mb@bu3sch.de] 
Sent: Wednesday, August 23, 2006 1:20 PM
To: Simon Barber
Cc: Jiri Benc; linville@tuxdriver.com; netdev@vger.kernel.org
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()

On Wednesday 23 August 2006 22:10, Simon Barber wrote:
> The DMA ring forms a queue of frames. Frames live in that queue for 
> some time before they are transmitted. This is a source of latency 
> between the software process that puts  the frames in the queue and 
> the point in time when they are actually transmitted.

Yes, sure. But I don't see how shortening that queue reduces the time.
Frames are always processed by the device as fast as possible to a given
"end-pointer". That end-pointer is updated on the fly as packets come
in. So if enough packets come in the device keeps circling the ring. No
matter how large it is.
The issue that we must prevent is a ring overflow by providing a
sufficiently _large_ (not small) ring. The larger the ring the better.
Theoretically an infinite ring size would be perfect, but we don't want
that for obvious memory issues. ;) So we try to keep ring size down to a
sane amount, where it's damn unlikely to ever overflow, to reduce memory
usage (and only memory usage).

--
Greetings Michael.
