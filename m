From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] net/tipc: initialize security state for new connection
 socket
Date: Wed, 8 Jul 2015 13:09:22 +0800
Message-ID: <559CB082.4080403@windriver.com>
References: <1436276625-3325-1-git-send-email-sds@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <paul@paul-moore.com>, <linux-security-module@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Stephen Smalley <sds@tycho.nsa.gov>, <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45703 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbbGHFJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 01:09:34 -0400
In-Reply-To: <1436276625-3325-1-git-send-email-sds@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2015 09:43 PM, Stephen Smalley wrote:
> Calling connect() with an AF_TIPC socket would trigger a series
> of error messages from SELinux along the lines of:
> SELinux: Invalid class 0
> type=AVC msg=audit(1434126658.487:34500): avc:  denied  { <unprintable> }
>   for pid=292 comm="kworker/u16:5" scontext=system_u:system_r:kernel_t:s0
>   tcontext=system_u:object_r:unlabeled_t:s0 tclass=<unprintable>
>   permissive=0
> 
> This was due to a failure to initialize the security state of the new
> connection sock by the tipc code, leaving it with junk in the security
> class field and an unlabeled secid.  Add a call to security_sk_clone()
> to inherit the security state from the parent socket.
> 
> Reported-by: Tim Shearer <tim.shearer@overturenetworks.com>
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> Acked-by: Paul Moore <paul@paul-moore.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/socket.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 46b6ed5..3a7567f 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -2007,6 +2007,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
>  	res = tipc_sk_create(sock_net(sock->sk), new_sock, 0, 1);
>  	if (res)
>  		goto exit;
> +	security_sk_clone(sock->sk, new_sock->sk);
>  
>  	new_sk = new_sock->sk;
>  	new_tsock = tipc_sk(new_sk);
> 
