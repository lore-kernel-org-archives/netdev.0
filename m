From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: Add process name and pid to deprecation warnings
Date: Fri, 03 Jan 2014 10:27:37 -0500
Message-ID: <52C6D6E9.3060203@gmail.com>
References: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com> <1388695167-21896-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:63053 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbaACP1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 10:27:42 -0500
In-Reply-To: <1388695167-21896-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2014 03:39 PM, Neil Horman wrote:
> Recently I updated the sctp socket option deprecation warnings to be both a bit
> more clear and ratelimited to prevent user processes from spamming the log file.
> Ben Hutchings suggested that I add the process name and pid to these warnings so
> that users can tell who is responsible for using the deprecated apis.  This
> patch accomplishes that.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: netdev@vger.kernel.org

Looks good to me, thanks.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>


-vlad

> 
> ---
> Change Notes
> v2) Convert formatting to use  %s (%d) rather than %s (pid %d) as per request
> from Ben
> ---
>  net/sctp/socket.c | 24 ++++++++++++++++++------
>  1 file changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index e9c5121..bcc71aa 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2579,8 +2579,10 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
>  			return 0;
>  	} else if (optlen == sizeof(struct sctp_assoc_value)) {
>  		pr_warn_ratelimited(DEPRECATED
> +				    "%s (%d) "
>  				    "Use of struct sctp_assoc_value in delayed_ack socket option.\n"
> -				    "Use struct sctp_sack_info instead\n");
> +				    "Use struct sctp_sack_info instead\n",
> +				    current->comm, task_pid_nr(current));
>  		if (copy_from_user(&params, optval, optlen))
>  			return -EFAULT;
>  
> @@ -2996,8 +2998,10 @@ static int sctp_setsockopt_maxseg(struct sock *sk, char __user *optval, unsigned
>  
>  	if (optlen == sizeof(int)) {
>  		pr_warn_ratelimited(DEPRECATED
> +				    "%s (%d) "
>  				    "Use of int in maxseg socket option.\n"
> -				    "Use struct sctp_assoc_value instead\n");
> +				    "Use struct sctp_assoc_value instead\n",
> +				    current->comm, task_pid_nr(current));
>  		if (copy_from_user(&val, optval, optlen))
>  			return -EFAULT;
>  		params.assoc_id = 0;
> @@ -3255,8 +3259,10 @@ static int sctp_setsockopt_maxburst(struct sock *sk,
>  
>  	if (optlen == sizeof(int)) {
>  		pr_warn_ratelimited(DEPRECATED
> +				    "%s (%d) "
>  				    "Use of int in max_burst socket option deprecated.\n"
> -				    "Use struct sctp_assoc_value instead\n");
> +				    "Use struct sctp_assoc_value instead\n",
> +				    current->comm, task_pid_nr(current));
>  		if (copy_from_user(&val, optval, optlen))
>  			return -EFAULT;
>  	} else if (optlen == sizeof(struct sctp_assoc_value)) {
> @@ -4577,8 +4583,10 @@ static int sctp_getsockopt_delayed_ack(struct sock *sk, int len,
>  			return -EFAULT;
>  	} else if (len == sizeof(struct sctp_assoc_value)) {
>  		pr_warn_ratelimited(DEPRECATED
> +				    "%s (%d) "
>  				    "Use of struct sctp_assoc_value in delayed_ack socket option.\n"
> -				    "Use struct sctp_sack_info instead\n");
> +				    "Use struct sctp_sack_info instead\n",
> +				    current->comm, task_pid_nr(current));
>  		if (copy_from_user(&params, optval, len))
>  			return -EFAULT;
>  	} else
> @@ -5223,8 +5231,10 @@ static int sctp_getsockopt_maxseg(struct sock *sk, int len,
>  
>  	if (len == sizeof(int)) {
>  		pr_warn_ratelimited(DEPRECATED
> +				    "%s (%d) "
>  				    "Use of int in maxseg socket option.\n"
> -				    "Use struct sctp_assoc_value instead\n");
> +				    "Use struct sctp_assoc_value instead\n",
> +				    current->comm, task_pid_nr(current));
>  		params.assoc_id = 0;
>  	} else if (len >= sizeof(struct sctp_assoc_value)) {
>  		len = sizeof(struct sctp_assoc_value);
> @@ -5316,8 +5326,10 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
>  
>  	if (len == sizeof(int)) {
>  		pr_warn_ratelimited(DEPRECATED
> +				    "%s (%d) "
>  				    "Use of int in max_burst socket option.\n"
> -				    "Use struct sctp_assoc_value instead\n");
> +				    "Use struct sctp_assoc_value instead\n",
> +				    current->comm, task_pid_nr(current));
>  		params.assoc_id = 0;
>  	} else if (len >= sizeof(struct sctp_assoc_value)) {
>  		len = sizeof(struct sctp_assoc_value);
> 
