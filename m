From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/3] genetlink: disallow subscribing to unknown
 mcast groups
Date: Fri, 16 Jan 2015 17:20:38 -0500 (EST)
Message-ID: <20150116.172038.1258592815037521446.davem@davemloft.net>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	<1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff.layton@primarydata.com,
	sedat.dilek@gmail.com, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbbAPWUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 17:20:41 -0500
In-Reply-To: <1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 16 Jan 2015 11:37:13 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Jeff Layton reported that he could trigger the multicast unbind warning
> in generic netlink using trinity. I originally thought it was a race
> condition between unregistering the generic netlink family and closing
> the socket, but there's a far simpler explanation: genetlink currently
> allows subscribing to groups that don't (yet) exist, and the warning is
> triggered when unsubscribing again while the group still doesn't exist.
> 
> Originally, I had a warning in the subscribe case and accepted it out of
> userspace API concerns, but the warning was of course wrong and removed
> later.
> 
> However, I now think that allowing userspace to subscribe to groups that
> don't exist is wrong and could possibly become a security problem:
> Consider a (new) genetlink family implementing a permission check in
> the mcast_bind() function similar to the like the audit code does today;
> it would be possible to bypass the permission check by guessing the ID
> and subscribing to the group it exists. This is only possible in case a
> family like that would be dynamically loaded, but it doesn't seem like a
> huge stretch, for example wireless may be loaded when you plug in a USB
> device.
> 
> To avoid this reject such subscription attempts.
> 
> If this ends up causing userspace issues we may need to add a workaround
> in af_netlink to deny such requests but not return an error.
> 
> Reported-by: Jeff Layton <jeff.layton@primarydata.com>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
