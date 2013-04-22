From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Mon, 22 Apr 2013 16:08:34 -0400 (EDT)
Message-ID: <20130422.160834.1941810644323096368.davem@davemloft.net>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259Ab3DVUIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:08:36 -0400
In-Reply-To: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is broken.  Every time I see someone export new things from IPV6
and then try to use those symbols in some other unrelated module, it
is a huge red flag.

You can't call into IPV6 protected symbols unless VXLAN and IPV6 are
configured identically.

So with your changes, with VXLAN=y and IPV6=m, you'll get link errors.
I could see this just by looking at your patch, I didn't have to even
try to build it.

Please do not fix this by adding Kconfig dependencies, you have to
find another way.  In bonding and bridging, we've made it such that
you can configure them in any combination whatsoever with ipv6 and
everything works properly.  Most of them time this can be accomplished
by moving things into the explicit "obj-y" objects in
net/ipv6/Makefile

If you are adding stateful dependencies upon ipv6 (you want to inspect
the ipv6 routes or something like that), I'm sorry but I really don't
want any hard dependies on ipv6's internal state, we can't export that
properly.
