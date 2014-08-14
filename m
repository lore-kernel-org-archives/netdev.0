From: David Miller <davem@davemloft.net>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 16:20:24 -0700 (PDT)
Message-ID: <20140814.162024.2218312002979492106.davem@davemloft.net>
References: <53ECFDAB.5010701@intel.com>
	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<53ED4354.9090904@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078AbaHNXUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 19:20:25 -0400
In-Reply-To: <53ED4354.9090904@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 14 Aug 2014 16:16:36 -0700

> Are you sure about each socket having it's own DST?  Everything I see
> seems to indicate it is somehow associated with IP.

Right it should be, unless you have exception entries created by path
MTU or redirects.

WRT prequeue, it does the right thing for dumb apps that block in
receive.  But because it causes the packet to cross domains as it
does, we can't do a lot of tricks which we normally can do, and that's
why the refcounting on the dst is there now.

Perhaps we can find a clever way to elide that refcount, who knows.
