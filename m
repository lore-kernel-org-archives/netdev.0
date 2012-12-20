From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Lockdep warning in vxlan
Date: Thu, 20 Dec 2012 08:34:36 -0800
Message-ID: <20121220083436.0c7fc33f@nehalam.linuxnetplumber.net>
References: <50D31A00.7060905@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Yan Burman <yanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48109 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317Ab2LTQfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 11:35:52 -0500
In-Reply-To: <50D31A00.7060905@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2012 16:00:32 +0200
Yan Burman <yanb@mellanox.com> wrote:

> Hi.
> 
> When working with vxlan from current net-next, I got a lockdep warning 
> (below).
> It seems to happen when I have host B pinging host A and while the pings 
> continue,
> I do "ip link del" on the vxlan interface on host A. The lockdep warning 
> is on host A.
> Tell me if you need some more info.
> 

Looks like the case of nested ARP requests, the initial request is coming
from neigh_timer (ARP retransmit), but inside neigh_probe the lock
is dropped?
