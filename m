From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9260] New: tipc_config.h is not installed
 when doing "make headers_install"
Date: Tue, 30 Oct 2007 01:20:11 -0700 (PDT)
Message-ID: <20071030.012011.34579301.davem@davemloft.net>
References: <bug-9260-10286@http.bugzilla.kernel.org/>
	<20071029120716.4957ded1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux@izac.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38535
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751849AbXJ3IUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 04:20:44 -0400
In-Reply-To: <20071029120716.4957ded1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 29 Oct 2007 12:07:16 -0700

> On Mon, 29 Oct 2007 09:10:26 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9260
 ...
> > Problem Description:
> > When doing "make headers_install" the file tipc_config.h is not installed. It
> > describes the interface to configure the TIPC module and it is needed when
> > building the config utility (tipc-config). 
> > Adding the following line to include/linux/Kbuild solves this:
> > header-y += tipc_config.h
> > 

Fair enough, I'll commit the following and submit to
-stable as well.

>From 502ef38da15d817f8e67acefc12dc2212f7f8aa1 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Tue, 30 Oct 2007 01:19:19 -0700
Subject: [PATCH] [TIPC]: Add tipc_config.h to include/linux/Kbuild.

Needed, as reported in:

http://bugzilla.kernel.org/show_bug.cgi?id=9260

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/Kbuild |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 6a65231..bd33c22 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -149,6 +149,7 @@ header-y += ticable.h
 header-y += times.h
 header-y += tiocl.h
 header-y += tipc.h
+header-y += tipc_config.h
 header-y += toshiba.h
 header-y += ultrasound.h
 header-y += un.h
-- 
1.5.2.5

