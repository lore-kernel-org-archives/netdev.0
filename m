From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: How does TX flow control work?
Date: Wed, 3 Jan 2007 18:52:03 +0100
Message-ID: <20070103185203.2754e059@griffin.suse.cz>
References: <459A5945.80909@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:53865 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750936AbXACRuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 12:50:06 -0500
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <459A5945.80909@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 02 Jan 2007 14:08:21 +0100, Jan Kiszka wrote:
> What I (think to) understand is that a low-level drivers call
> ieee80211_stop_queue() if they run out of buffers. That flips a
> per-queue bit (IEEE80211_LINK_STATE_XOFF), prevents that any further
> frame is passed to the low-level TX routine,

Correct.

> and can cause that up to
> *one* packet per queue is stored in
> ieee80211_local::pending_packets[queue].

This is needed due to fragmented frames. After resume, passing of
fragments to the driver has to continue where it was stopped. Returning
the half-sent fragmented frame to the 802.11 qdisc wasn't possible
until recently (I think the conversion of master interface to native
802.11 type could allow that now - but it's probably not worth the
effort).

> But it looks to me like nothing
> prevents ieee80211_tx() being invoked even in case that there is already
> some stuff in that single-packet storage.

The 802.11 qdisc (see wme_qdiscop_dequeue) takes care of that.

> That in turn triggers WARN_ONs in ieee80211_tx() under high load for me
> (with rt2500usb). And it should also cause orphaned skbs because the
> storage is overwritten in that case. Either I'm blind or something is
> fishy...

You are most likely hitting some bug. Could you post more information
please?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
