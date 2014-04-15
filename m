From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_gre: don't allow to remove the fb_tunnel_dev
Date: Tue, 15 Apr 2014 00:04:04 -0400 (EDT)
Message-ID: <20140415.000404.2110427476393772943.davem@davemloft.net>
References: <1397488298-19931-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaDOEEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 00:04:07 -0400
In-Reply-To: <1397488298-19931-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 14 Apr 2014 17:11:38 +0200

> It's possible to remove the FB tunnel with the command 'ip link del ip6gre0' but
> this is unsafe, the module always supposes that this device exists. For example,
> ip6gre_tunnel_lookup() may use it unconditionally.
> 
> Let's add a rtnl handler for dellink, which will never remove the FB tunnel (we
> let ip6gre_destroy_tunnels() do the job).
> 
> Introduced by commit c12b395a4664 ("gre: Support GRE over IPv6").
> 
> CC: Dmitry Kozlov <xeb@mail.ru>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I don't see how we ever get rid of fb_tunnel_dev and can therefore
remove the module successfully.

It is created by the per-netns initialization, but since it isn't
added to the hashes I don't see how the per-netns exit code can
end up unregistering and freeing it up.

How is this supposed to work?
