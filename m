From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: add netnotifier event for upper device
 change
Date: Sun, 26 May 2013 00:37:15 -0700 (PDT)
Message-ID: <20130526.003715.728961070406338721.davem@davemloft.net>
References: <1369491130-7412-1-git-send-email-jiri@resnulli.us>
	<20130525.231413.1228840457158928295.davem@davemloft.net>
	<20130526071039.GA1560@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	alexander.h.duyck@intel.com, xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759091Ab3EZHhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 03:37:18 -0400
In-Reply-To: <20130526071039.GA1560@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 26 May 2013 09:10:39 +0200

> Sun, May 26, 2013 at 08:14:13AM CEST, davem@davemloft.net wrote:
>>If someone is looking for a useful project, switching networking over to
>>a more typed notifier system would be a worthwhile improvement.
>>
>>It's hard to right now to communicate what changed beyond "action X
>>happened to this object, you have to check to see exactly how it
>>changed"
> 
> Hmm. Do you have something particular in mind? My first thought was
> passing some union instead of NETDEV_* numbers.

Part of the problem is that notifiers are untyped.

So you can say "NETDEV_* means struct foo" but nothing in the C
typing system will enforce this, so errors are inevitable.

Perhaps one level of encapsulation will help:

static inline call_netdevice_feat_change(struct net_device *dev,
					 netdev_features_t old,
					 netdev_features_t new)
{
	struct netdevice_feat_change_info info;

	info.dev = dev;
	info.old = old;
	info.new = new;
	call_netdevice_notifiers(NETDEV_FEAT_CHANGE, &info);
}

>>This came up recently with the IFF_NOARP stuff.
> 
> Can you point me to the discussion?

It's in this patchwork thread:

http://patchwork.ozlabs.org/patch/245256/
