From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4] sctp: check the rto_min and rto_max
Date: Thu, 5 Dec 2013 08:32:17 -0500
Message-ID: <20131205133217.GA20349@hmsreliant.think-freely.org>
References: <529FE2AD.5020700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44027 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab3LENcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 08:32:39 -0500
Content-Disposition: inline
In-Reply-To: <529FE2AD.5020700@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 10:19:25AM +0800, Wang Weidong wrote:
> rto_min should be smaller than rto_max while rto_max should be larger
> than rto_min. Add two proc_handler for the checking. Add the check in
> sctp_setsockopt_rtoinfo.
> delete a blank line in proc_sctp_do_hmac_alg() declaration.
> 
> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/socket.c |  5 ++++
>  net/sctp/sysctl.c | 74 +++++++++++++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 74 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 72046b9..2e1af1b 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2818,6 +2818,11 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
>  	if (copy_from_user(&rtoinfo, optval, optlen))
>  		return -EFAULT;
>  
> +	if (rtoinfo.srto_min < 1 ||
> +	    rtoinfo.srto_max > 86400000 ||
These should be defiend to some descriptive value.
