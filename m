From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] net/sched/sch_generic.c: fix an error pointer
Date: Sat, 21 Jun 2008 20:55:26 +0100
Message-ID: <20080621195526.GA25715@hack.netcabo.pt>
References: <20080619153714.5614d5be@hack> <20080619.161108.23678497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wcong@critical-links.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:28245 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbYFUT55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 15:57:57 -0400
Received: by an-out-0708.google.com with SMTP id d40so412900and.103
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 12:57:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080619.161108.23678497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2008 at 04:11:08PM -0700, David Miller wrote:
>From: WANG Cong <wcong@critical-links.com>
>Date: Thu, 19 Jun 2008 15:37:14 +0100
>
>> ERR_PTR() ususally encodes an negative errno, not positive.
>> 
>> Note, in the following patch, 'err' is initialized as:
>> 
>> int err = -ENOBUFS;
>> 
>> Signed-off-by: WANG Cong <wcong@critical-links.com>
>
>Patch is whitespace corruped and line wrapped by your
>email client.
>
>Please fix this and resubmit, thank you.

I am very sorry for this. Resend it with mutt. :-)

--------------->

ERR_PTR() ususally encodes an negative errno, not positive.

Note, in the following patch, 'err' is initialized as:

int err = -ENOBUFS;

Signed-off-by: WANG Cong <wcong@critical-links.com>
Cc: David Miller <davem@davemloft.net>
Cc:  Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

---
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d355e5e..13afa72 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -468,7 +468,7 @@ struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops)
 
 	return sch;
 errout:
-	return ERR_PTR(-err);
+	return ERR_PTR(err);
 }
 
 struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops,
