From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Date: Tue, 22 Apr 2008 11:40:42 +0900 (JST)
Message-ID: <20080422.114042.70459573.yoshfuji@linux-ipv6.org>
References: <20080421.023503.242108516.davem@davemloft.net>
	<20080421134844.GC12221@ghostprotocols.net>
	<20080421.142857.234288906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org, dccp@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34322 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbYDVCis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 22:38:48 -0400
In-Reply-To: <20080421.142857.234288906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080421.142857.234288906.davem@davemloft.net> (at Mon, 21 Apr 2008 14:28:57 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> Thanks for reviewing, patch applied.

Sorry I have just realized set_normalized_timespec() (used in timespec_sub())
is not exported, and link will fail because of it...

What should I/we do?  Send the patch to LKML as well?

---

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
diff --git a/kernel/time.c b/kernel/time.c
index a5ec013..35d373a 100644
--- a/kernel/time.c
+++ b/kernel/time.c
@@ -379,6 +379,7 @@ void set_normalized_timespec(struct time
 	ts->tv_sec = sec;
 	ts->tv_nsec = nsec;
 }
+EXPORT_SYMBOL(set_normalized_timespec);
 
 /**
  * ns_to_timespec - Convert nanoseconds to timespec


--yoshfuji
