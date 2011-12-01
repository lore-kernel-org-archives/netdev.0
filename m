From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Thu, 1 Dec 2011 20:50:18 +0400
Message-ID: <20111201165018.GA19451@tugrik.mns.mnsspb.ru>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com> <1322585184.2465.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111129.124715.163094087536706067.davem@davemloft.net> <CA+mtBx_-_4zzweT61vYKe-c8ngMO9jF5PoYa4gC1aNKREjbwgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:46377 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407Ab1LAQwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 11:52:30 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx_-_4zzweT61vYKe-c8ngMO9jF5PoYa4gC1aNKREjbwgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 10:31:03AM -0800, Tom Herbert wrote:
> On Tue, Nov 29, 2011 at 9:47 AM, David Miller <davem@davemloft.net> wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 29 Nov 2011 17:46:24 +0100
> >
> >> I did sucessful tests with tg3 (I'll provide the patch for bnx2 shortly)
> >>
> >> Some details probably can be polished, but I believe your v4 is ready
> >> for inclusion.
> >>
> >> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> >
> > Agreed, all applied to net-next, thanks!
> >
> > Tom, please keep an eye out for regression or suggestion reports.
> >
> 
> Will do.  I am well aware of how invasive this is in the data path ;-)
>  I'll add a doc describing BQL also.
> 
> By the way, the way to disable BQL at runtime is the 'echo max >
> /sys/class/net/eth<n>/queues/tx-<m>/byte_queue_limits/limit_min

One "regression" is it is now not possible to disable BQL at compile time,
because CONFIG_BQL can't be set to "n" via usual ways.

Description and patch below. Thanks.


---- 8< ----
From: Kirill Smelkov <kirr@mns.spb.ru>
Date: Thu, 1 Dec 2011 20:36:06 +0400
Subject: [PATCH] net: Allow users to set CONFIG_BQL=n

Commit 114cf580 (bql: Byte queue limits) added new config option without
description, which means neither `make oldconfig` nor `make menuconfig`
ask for it -- the option is simply set to default y automatically.

Make the option actually configurable via adding stub description.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>
---
 net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index 2d99873..c120631 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -240,7 +240,7 @@ config NETPRIO_CGROUP
 	  a per-interface basis
 
 config BQL
-	boolean
+	boolean "Byte Queue Limits"
 	depends on SYSFS
 	select DQL
 	default y
-- 
1.7.8.rc4.327.g599a2
