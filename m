From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] zd1211rw-mac80211: limit URB buffering in tx path
Date: Tue, 1 May 2007 12:34:11 +0200
Message-ID: <20070501123411.081c43c6@logostar.upir.cz>
References: <20070501030100.BDE3D7B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, kune@deine-taler.de
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47287 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031153AbXEAKeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 06:34:17 -0400
In-Reply-To: <20070501030100.BDE3D7B409F@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  1 May 2007 04:01:00 +0100 (BST), Daniel Drake wrote:
> The old code allowed unlimited buffing of tx frames in URBs
> submitted for transfer to the device. This patch stops the
> ieee80211_hw queue(s) if to many URBs are ready for submit to the
> device. Actually the ZD1211 device supports currently only one
> queue.

This doesn't look correct to me. The limits should be per queue and you
should always stop queues selectively.

The ieee80211_stop_queues/ieee80211_wake_queues are for another purposes
and should be used only rarely - one example is Michael Buesch's comment
about a need to stop sending frames while tuning to a new channel in a
workqueue.

> +/**
> + * wake_queues - wakes all queues
> + * @hw: a &struct ieee80211_hw pointer
> + *
> + * Such a function is not provided by mac80211, so we have to provide them on
> + * our own.
> + */
> +static void wake_queues(struct ieee80211_hw *hw)

It is :-) Look for ieee80211_wake_queues. But as I said, you shouldn't need
that.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
