From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 22:57:25 +0200
Message-ID: <200608232257.25590.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B5E4@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:32485
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965199AbWHWU54
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 16:57:56 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B5E4@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 22:32, Simon Barber wrote:
> Right - and what I'm proposing is that we don't just count the number of
> frames in the ring - but also count the amount of frame time the ring
> takes too. This way if there are a number of large, slow frames we can
> stop adding more frames into the ring well before we reach the limit on
> the number of frames. 

Ah, now I understand what you are trying to explain. :)
But why do we actually _want_ to stop a DMA ring, if it's
not full (has free descriptors)? I can't see any benefit on
it. Adding frames to the ring is done on the fly without
stopping or otherwise interferring with any running transmissions
queued earlier.
I would say we don't care about the time it takes for the
ring to go into idle on the d80211 level. I think the only thing
we care at d80211 level is: Can we queue another frame?
We have that logic. If a queue is not stopped, we can queue another
frame.

Or do you want to make the qdisc intelligent? Say, it drops
a few beacons, if there are already packets queued for the next
300ms, for example. Do you want to optimize latency of payload
data by dropping low-priority packets while the queue is
heavily loaded?
I can't see another usage for time based DMA ring accounting
in d80211, yet.

-- 
Greetings Michael.
