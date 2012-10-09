From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] RDS: fix rds-ping spinlock recursion
Date: Tue, 09 Oct 2012 13:58:08 -0400 (EDT)
Message-ID: <20121009.135808.69869742229483434.davem@davemloft.net>
References: <5073AEB7.9060309@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, venkat.x.venkatsubra@oracle.com,
	dan.carpenter@oracle.com, james.l.morris@oracle.com,
	netdev@vger.kernel.org
To: jeff.liu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195Ab2JIR6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 13:58:10 -0400
In-Reply-To: <5073AEB7.9060309@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Liu <jeff.liu@oracle.com>
Date: Tue, 09 Oct 2012 12:57:27 +0800

> This is the revised patch for fixing rds-ping spinlock recursion according to Venkat's suggestions.
> 
> RDS ping/pong over TCP feature has been broken for years(2.6.39 to 3.6.0) since we
> have to set TCP cork and call kernel_sendmsg() between ping/pong which both need to
> lock "struct sock *sk". However, this lock has already been hold before rds_tcp_data_ready()
> callback is triggerred. As a result, we always facing spinlock resursion which would resulting
> in system panic.
> 
> Given that RDS ping is only used to test the connectivity and not for serious performance measurements,
> we can queue the pong transmit to rds_wq as a delayed response.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> CC: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: James Morris <james.l.morris@oracle.com>
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>

Applied and queued up for -stable, thanks.
