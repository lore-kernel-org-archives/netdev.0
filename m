From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] sctp: fix a problem with net_namespace
Date: Mon, 27 Jan 2014 06:49:04 -0500
Message-ID: <20140127114904.GA17143@hmsreliant.think-freely.org>
References: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vyasevich@gmail.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33691 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbaA0LtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 06:49:20 -0500
Content-Disposition: inline
In-Reply-To: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 27, 2014 at 11:49:01AM +0800, Wang Weidong wrote:
> fix a problem with net_namespace, and optimize
> the sctp_sysctl_net_register.
> 
> Wang Weidong (2):
>   sctp: fix a missed .data initialization
>   sctp: optimize the sctp_sysctl_net_register
> 
>  net/sctp/sysctl.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> -- 
> 1.7.12
> 
> 
> 
I don't see that either of these patches are needed.  In sctp_init_net, the
sctp_hmac_alg pointer gets initalized before calling sctp_sysctl_net_register,
and sctp_proc_do_hmac_alg is written to specifically expect NULL values, so this
code may change behavior regarding default cookie selection.

This was coded so that poniters to entires in the string table could be used,
rather than needing to allocate or maintain character buffers.  That said, it
does look like that for loop in sctp_sysctl_register_table might compute an odd
offset when cloning the table.  I think the right fix for that is likely to just
move the sysctl value initalization in sctp_init_net to below the sysctl
register function.

Neil
