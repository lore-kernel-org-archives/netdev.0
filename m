From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 22:20:06 +0200
Message-ID: <200608232220.07093.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B5DC@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:42710
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965179AbWHWUVG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 16:21:06 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B5DC@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 22:10, Simon Barber wrote:
> The DMA ring forms a queue of frames. Frames live in that queue for some
> time before they are transmitted. This is a source of latency between
> the software process that puts  the frames in the queue and the point in
> time when they are actually transmitted.

Yes, sure. But I don't see how shortening that queue reduces
the time. Frames are always processed by the device as fast as
possible to a given "end-pointer". That end-pointer is updated
on the fly as packets come in. So if enough packets come in
the device keeps circling the ring. No matter how large it is.
The issue that we must prevent is a ring overflow by providing
a sufficiently _large_ (not small) ring. The larger the ring
the better. Theoretically an infinite ring size would be perfect,
but we don't want that for obvious memory issues. ;)
So we try to keep ring size down to a sane amount, where it's
damn unlikely to ever overflow, to reduce memory usage (and only
memory usage).

-- 
Greetings Michael.
