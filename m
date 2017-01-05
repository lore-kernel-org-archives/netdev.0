From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Synchronize access to mailbox
Date: Thu, 05 Jan 2017 11:05:32 -0500 (EST)
Message-ID: <20170105.110532.154981132261843828.davem@davemloft.net>
References: <1483595590-12932-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
        ganeshgr@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdAEQO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:14:56 -0500
In-Reply-To: <1483595590-12932-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu,  5 Jan 2017 11:23:10 +0530

> @@ -844,6 +848,10 @@ struct adapter {
>  	struct work_struct db_drop_task;
>  	bool tid_release_task_busy;
>  
> +	/* lock for mailbox cmd list */
> +	spinlock_t mbox_lock;
> +	struct mbox_list mlist;
> +
 ...
> @@ -4707,6 +4707,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	spin_lock_init(&adapter->stats_lock);
>  	spin_lock_init(&adapter->tid_release_lock);
>  	spin_lock_init(&adapter->win0_lock);
> +	spin_lock_init(&adapter->mbox_lock);
> +
> +	INIT_LIST_HEAD(&adapter->mbox_list.list);

It is absolutely impossible that you even compiled this code.
