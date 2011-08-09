From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 1/6] Security: define security_sk_getsecid.
Date: Tue, 09 Aug 2011 09:13:39 -0700
Message-ID: <4E415CB3.8020202@schaufler-ca.com>
References: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com> <1312874910-31010-2-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, sds@tycho.nsa.gov,
	Casey Schaufler <casey@schaufler-ca.com>
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm10.bullet.mail.sp2.yahoo.com ([98.139.91.80]:27444 "HELO
	nm10.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753595Ab1HIQNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 12:13:43 -0400
In-Reply-To: <1312874910-31010-2-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/2011 12:28 AM, rongqing.li@windriver.com wrote:
> From: Roy.Li <rongqing.li@windriver.com>
>
> Define security_sk_getsecid to get the security id of a sock.

Why are you requesting the secid when you're just going to
use it to get the secctx? Why not ask for that directly?
Is there ever a case where you only want the secid?

>
> Signed-off-by: Roy.Li <rongqing.li@windriver.com>
> ---
>  include/linux/security.h |    6 ++++++
>  security/security.c      |    6 ++++++
>  2 files changed, 12 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/security.h b/include/linux/security.h
> index ebd2a53..739ac39 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -2560,6 +2560,7 @@ int security_sk_alloc(struct sock *sk, int family, gfp_t priority);
>  void security_sk_free(struct sock *sk);
>  void security_sk_clone(const struct sock *sk, struct sock *newsk);
>  void security_sk_classify_flow(struct sock *sk, struct flowi *fl);
> +void security_sk_getsecid(struct sock *sk, u32 *secid);
>  void security_req_classify_flow(const struct request_sock *req, struct flowi *fl);
>  void security_sock_graft(struct sock*sk, struct socket *parent);
>  int security_inet_conn_request(struct sock *sk,
> @@ -2701,6 +2702,11 @@ static inline void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
>  {
>  }
>  
> +static inline void security_sk_getsecid(struct sock *sk, u32 *secid)
> +{
> +	*secid = 0;
> +}
> +
>  static inline void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
>  {
>  }
> diff --git a/security/security.c b/security/security.c
> index 0e4fccf..b0e0825 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -1104,6 +1104,12 @@ void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
>  }
>  EXPORT_SYMBOL(security_sk_classify_flow);
>  
> +void security_sk_getsecid(struct sock *sk, u32 *secid)
> +{
> +	security_ops->sk_getsecid(sk, secid);
> +}
> +EXPORT_SYMBOL(security_sk_getsecid);
> +
>  void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
>  {
>  	security_ops->req_classify_flow(req, fl);

