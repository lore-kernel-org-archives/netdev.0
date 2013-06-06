From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v3 3/3] igmp: convert RTNL lock to a spinlock
Date: Wed, 05 Jun 2013 19:40:00 -0700
Message-ID: <1370486400.24311.316.camel@edumazet-glaptop>
References: <1370485211-11498-1-git-send-email-amwang@redhat.com>
	 <1370485211-11498-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:61717 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756879Ab3FFCkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 22:40:03 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so2675102pdi.25
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 19:40:02 -0700 (PDT)
In-Reply-To: <1370485211-11498-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-06 at 10:20 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> It is not necessary to hold RTNL lock to protect mc_list,
> at least IPv6 mcast is using a local spinlock, IPv4 can do
> this too. This patch converts RTNL lock+RCU to spinlock+RCU.
> 

Why are you doing this ? 

Really, holding a spinlock in this code instead of a mutex brings all
kind of problems.

For example, you have to use GFP_ATOMIC allocations instead of
GFP_KERNEL

Not counting the race/bug you added in ip_mc_join_group()
