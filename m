From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Correctly propagate promisc|allmulti flags in
 notifier.
Date: Thu, 14 May 2015 00:55:40 -0400 (EDT)
Message-ID: <20150514.005540.60193741590743501.davem@davemloft.net>
References: <1431478394-8257-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbbENEzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:55:43 -0400
In-Reply-To: <1431478394-8257-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 12 May 2015 20:53:14 -0400

> Currently vlan notifier handler will try to update all vlans
> for a device when that device comes up.  A problem occurs,
> however, when the vlan device was set to promiscuous, but not
> by the user (ex: a bridge).  In that case, dev->gflags are
> not updated.  What results is that the lower device ends
> up with an extra promiscuity count.  Here are the
> backtraces that prove this:
 ...
> The above comes from the setting the vlan device to IFF_UP state.
 ...
> And this one comes from the notification code.  What we end
> up with is a vlan with promiscuity count of 1 and and a physical
> device with a promiscuity count of 2.  They should both have
> a count 1.
> 
> To resolve this issue, vlan code can use dev_get_flags() api
> which correctly masks promiscuity and allmulti flags.

Applied, thanks Vlad.

> Sign-off-by: Vlad Yasevich <vyasevic@redhat.com>

Note, it's "Signed-off-by:" not "Sign-off-by:" I fixed this for
you.
