From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net ipv6: Fix duplicate /proc/sys/net/ipv6/neigh
 directory entries.
Date: Mon, 21 Mar 2011 18:23:44 -0700 (PDT)
Message-ID: <20110321.182344.212691158.davem@davemloft.net>
References: <m14o6wjhm5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, sunkan@zappa.cx
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54853
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755028Ab1CVBXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:23:05 -0400
In-Reply-To: <m14o6wjhm5.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 21 Mar 2011 14:20:18 -0700

> 
> When I was fixing issues with unregisgtering tables under /proc/sys/net/ipv6/neigh
> by adding a mount point it appears I missed a critical ordering issue, in the
> ipv6 initialization.  I had not realized that ipv6_sysctl_register is called
> at the very end of the ipv6 initialization and in particular after we call
> neigh_sysctl_register from ndisc_init.
> 
> "neigh" needs to be initialized in ipv6_static_sysctl_register which is
> the first ipv6 table to initialized, and definitely before ndisc_init.
> This removes the weirdness of duplicate tables while still providing a
> "neigh" mount point which prevents races in sysctl unregistering.
> 
> This was initially reported at https://bugzilla.kernel.org/show_bug.cgi?id=31232
> Reported-by: sunkan@zappa.cx
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Applied, thanks.
