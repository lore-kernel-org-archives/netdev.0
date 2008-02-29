From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] [ATM]: Add error handling for proc_create fail
Date: Fri, 29 Feb 2008 07:42:56 -0500
Message-ID: <200802291242.m1TCguPo018924@cmf.nrl.navy.mil>
References: <47C7B79C.2010304@cn.fujitsu.com>
Reply-To: chas3@users.sourceforge.net
Cc: NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:50323 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbYB2MnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 07:43:20 -0500
In-reply-to: <47C7B79C.2010304@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it should be /proc/net/atm/foo not /proc/atm/foo i think.

In message <47C7B79C.2010304@cn.fujitsu.com>,Wang Chen writes:
>When proc_create() fail, we return -ENOMEM.
>
>Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>---
> net/atm/clip.c |    4 ++++
> net/atm/lec.c  |    4 ++++
> 2 files changed, 8 insertions(+), 0 deletions(-)
>
>diff --git a/net/atm/clip.c b/net/atm/clip.c
>index d30167c..57ed448 100644
>--- a/net/atm/clip.c
>+++ b/net/atm/clip.c
>@@ -963,6 +963,10 @@ static int __init atm_clip_init(void)
> 		struct proc_dir_entry *p;
> 
> 		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
>+		if (!p) {
>+			printk(KERN_ERR "Unable to initialize /proc/atm/arp\n");
>+			return -ENOMEM;
>+		}
> 	}
> #endif
> 
>diff --git a/net/atm/lec.c b/net/atm/lec.c
>index 0e450d1..532965d 100644
>--- a/net/atm/lec.c
>+++ b/net/atm/lec.c
>@@ -1250,6 +1250,10 @@ static int __init lane_module_init(void)
> 	struct proc_dir_entry *p;
> 
> 	p = proc_create("lec", S_IRUGO, atm_proc_root, &lec_seq_fops);
>+	if (!p) {
>+		printk(KERN_ERR "Unable to initialize /proc/atm/lec\n");
>+		return -ENOMEM;
>+	}
> #endif
> 
> 	register_atm_ioctl(&lane_ioctl_ops);
