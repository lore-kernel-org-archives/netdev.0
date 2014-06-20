From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] procfs: split proc_pid_status function
Date: Thu, 19 Jun 2014 21:22:54 -0700 (PDT)
Message-ID: <20140619.212254.967469891126477499.davem@davemloft.net>
References: <1403011478-20206-1-git-send-email-p.wilczek@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyungmin.park@samsung.com,
	juho80.son@samsung.com, b.zolnierkie@samsung.com
To: p.wilczek@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbaFTEW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:22:56 -0400
In-Reply-To: <1403011478-20206-1-git-send-email-p.wilczek@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Piotr Wilczek <p.wilczek@samsung.com>
Date: Tue, 17 Jun 2014 15:24:37 +0200

> +int proc_pid_status_mm(struct seq_file *m, struct pid_namespace *ns,
> +		       struct pid *pid, struct task_struct *task,
> +		       struct mm_struct *mm)
>  {
> -	struct mm_struct *mm = get_task_mm(task);
> -
>  	task_name(m, task);
>  	task_state(m, ns, pid, task);
>  
> -	if (mm) {
> +	if (mm)
>  		task_mem(m, mm);
> -		mmput(mm);

Neither proc_pid_status() nor the invocations in your second patch ever
invoke this function with a NULL mm, therefore you should never try to
explicitly handle the case.
