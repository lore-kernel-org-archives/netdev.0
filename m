From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix rtnetlink IFF_PROMISC and IFF_ALLMULTI
 handling
Date: Fri, 27 Jul 2012 13:46:50 -0700 (PDT)
Message-ID: <20120727.134650.366843201370833087.davem@davemloft.net>
References: <20120727145822.7efd10d4@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, makc@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab2G0Uqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 16:46:51 -0400
In-Reply-To: <20120727145822.7efd10d4@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 27 Jul 2012 14:58:22 +0200

> When device flags are set using rtnetlink, IFF_PROMISC and IFF_ALLMULTI
> flags are handled specially. Function dev_change_flags sets IFF_PROMISC and
> IFF_ALLMULTI bits in dev->gflags according to the passed value but
> do_setlink passes a result of rtnl_dev_combine_flags which takes those bits
> from dev->flags.
> 
> This can be easily trigerred by doing:
> 
> tcpdump -i eth0 &
> ip l s up eth0
> 
> ip sets IFF_UP flag in ifi_flags and ifi_change, which is combined with
> IFF_PROMISC by rtnl_dev_combine_flags, causing __dev_change_flags to set
> IFF_PROMISC in gflags.
> 
> Reported-by: Max Matveev <makc@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
