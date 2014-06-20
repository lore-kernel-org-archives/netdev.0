From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] Send process status in SCM_PROCINFO
Date: Thu, 19 Jun 2014 21:25:18 -0700 (PDT)
Message-ID: <20140619.212518.877673821198961194.davem@davemloft.net>
References: <1403011478-20206-1-git-send-email-p.wilczek@samsung.com>
	<1403011478-20206-2-git-send-email-p.wilczek@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyungmin.park@samsung.com,
	juho80.son@samsung.com, b.zolnierkie@samsung.com,
	jkaluza@redhat.com
To: p.wilczek@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbaFTEZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:25:21 -0400
In-Reply-To: <1403011478-20206-2-git-send-email-p.wilczek@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Piotr Wilczek <p.wilczek@samsung.com>
Date: Tue, 17 Jun 2014 15:24:38 +0200

> diff --git a/net/core/scm.c b/net/core/scm.c
> index b442e7e..57a18f7 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
 ...
> @@ -38,6 +41,12 @@
>  #include <net/scm.h>
>  #include <net/cls_cgroup.h>
>  
> +extern int proc_pid_status_mm(struct seq_file *, struct pid_namespace *,
> +			      struct pid *, struct task_struct *,
> +			      struct mm_struct *mm);

Nope, this is not where you should declare this new public function.

You should declare it instead in the appropriate procfs header file
under include/linux

Also, you should do so in your first patch, not this one.

I also want you to provide a header "[PATCH 0/2] ..." posting with
this patch series explaining in extreme detail why you need this
feature, what will use it, and why existing facilities can't be
used.
