From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mpls: Do not decrement alive counter for unregister
 events
Date: Sun, 12 Mar 2017 23:46:08 -0700 (PDT)
Message-ID: <20170312.234608.71611288620834149.davem@davemloft.net>
References: <1489183899-2397-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750793AbdCMGqK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:46:10 -0400
In-Reply-To: <1489183899-2397-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 10 Mar 2017 14:11:39 -0800

> Multipath routes can be rendered usesless when a device in one of the
> paths is deleted. For example:
> 
> $ ip -f mpls ro ls
> 100
> 	nexthop as to 200 via inet 172.16.2.2  dev virt12
> 	nexthop as to 300 via inet 172.16.3.2  dev br0
> 101
> 	nexthop as to 201 via inet6 2000:2::2  dev virt12
> 	nexthop as to 301 via inet6 2000:3::2  dev br0
> 
> $ ip li del br0
> 
> When br0 is deleted the other hop is not considered in
> mpls_select_multipath because of the alive check -- rt_nhn_alive
> is 0.
> 
> rt_nhn_alive is decremented once in mpls_ifdown when the device is taken
> down (NETDEV_DOWN) and again when it is deleted (NETDEV_UNREGISTER). For
> a 2 hop route, deleting one device drops the alive count to 0. Since
> devices are taken down before unregistering, the decrement on
> NETDEV_UNREGISTER is redundant.
> 
> Fixes: c89359a42e2a4 ("mpls: support for dead routes")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
