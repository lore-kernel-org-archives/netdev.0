From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] bonding: get rid of bond->lock
Date: Tue, 09 Sep 2014 17:32:46 -0700 (PDT)
Message-ID: <20140909.173246.407169326340249072.davem@davemloft.net>
References: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, vfalico@gmail.com,
	j.vosburgh@gmail.com, andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbaIJAcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:32:47 -0400
In-Reply-To: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue,  9 Sep 2014 23:16:56 +0200

> This patch-set removes the last users of bond->lock and converts the places
> that needed it for sync to use curr_slave_lock or RCU as appropriate.
> I've run this with lockdep and have stress-tested it via loading/unloading
> and enslaving/releasing in parallel while outputting bond's proc, I didn't
> see any issues. Please pay special attention to the procfs change, I've
> done about an hour of stress-testing on it and have checked that the event
> that causes the bonding to delete its proc entry (NETDEV_UNREGISTER) is
> called before ndo_uninit() and the freeing of the dev so any readers will
> sync with that. Also ran sparse checks and there were no splats.
> 
> v2: Add patch 0001/cxgb4 bond->lock removal, RTNL should be held in the
>     notifier call, the other patches are the same. Also tested with
>     allmodconfig to make sure there're no more users of bond->lock.
> Changes from the RFC:
>  use RCU in procfs instead of RTNL since RTNL might lead to a deadlock with
>  unloading and also is much slower. The bond destruction syncs with proc
>  via the proc locks. There's one new patch that converts primary_slave to
>  use RCU as it was necessary to fix a longstanding bugs in sysfs and
>  procfs and to make it easy to migrate bond's procfs to RCU. And of course
>  rebased on top of net-next current.
> 
> This is the first patch-set in a series that should simplify the bond's
> locking requirements and will make it easier to define the locking
> conditions necessary for the various paths. The goal is to rely on RTNL
> and rcu alone, an extra lock would be needed in a few special cases that
> would be documented very well.

Series applied, thanks.
