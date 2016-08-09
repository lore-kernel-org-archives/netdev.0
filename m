From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next 15/15] smc: proc-fs interface for smc
 connections
Date: Tue, 09 Aug 2016 14:40:47 -0700 (PDT)
Message-ID: <20160809.144047.675292713371843984.davem@davemloft.net>
References: <1470737580-43012-1-git-send-email-ubraun@linux.vnet.ibm.com>
	<1470737580-43012-16-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbcHIVkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:40:49 -0400
In-Reply-To: <1470737580-43012-16-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue,  9 Aug 2016 12:13:00 +0200

> +	sock_hold(&smc->sk);
 ...
> +out_line:
> +	seq_putc(m, '\n');
> +	sock_put(&smc->sk);

You hold the smc_proc_list_lock during this function's execution,
therefore the table cannot change and therefore the socket cannot
go away.

Therefore taking a reference count here is unnecessary overhead,
please remove it.
