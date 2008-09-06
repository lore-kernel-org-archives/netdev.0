From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC PATCH v5 05/14] smack: Fix missing calls to netlbl_skbuff_err()
Date: Fri, 05 Sep 2008 19:10:34 -0700
Message-ID: <48C1E69A.2050002@schaufler-ca.com>
References: <20080905231853.31840.57880.stgit@flek.lan> <20080905232344.31840.60714.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.prem.mail.sp1.yahoo.com ([98.136.44.63]:34325 "HELO
	smtp108.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752103AbYIFCKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 22:10:44 -0400
In-Reply-To: <20080905232344.31840.60714.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> Smack needs to call netlbl_skbuff_err() to let NetLabel do the necessary
> protocol specific error handling.
>
> Signed-off-by: Paul Moore <paul.moore@hp.com>
>   
Acked-by: Casey Schaufler <casey@schaufler-ca.com>

> ---
>
>  security/smack/smack_lsm.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 87d7541..6e2dc0b 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -2179,7 +2179,10 @@ static int smack_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  	 * This is the simplist possible security model
>  	 * for networking.
>  	 */
> -	return smk_access(smack, ssp->smk_in, MAY_WRITE);
> +	rc = smk_access(smack, ssp->smk_in, MAY_WRITE);
> +	if (rc != 0)
> +		netlbl_skbuff_err(skb, rc, 0);
> +	return rc;
>  }
>  
>  /**
>
>
> --
> This message was distributed to subscribers of the selinux mailing list.
> If you no longer wish to subscribe, send mail to majordomo@tycho.nsa.gov with
> the words "unsubscribe selinux" without quotes as the message.
>
>
>   

