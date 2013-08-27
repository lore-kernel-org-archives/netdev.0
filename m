From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] net: Check the correct namespace when spoofing pid over SCM_RIGHTS
Date: Mon, 26 Aug 2013 18:02:09 -0700
Message-ID: <8738pwndym.fsf@xmission.com>
References: <cover.1377196394.git.luto@amacapital.net>
	<cover.1377196394.git.luto@amacapital.net>
	<ff9dd301d8c91ec02362d52494b4a640f370bc68.1377196394.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: security@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ff9dd301d8c91ec02362d52494b4a640f370bc68.1377196394.git.luto@amacapital.net>
	(Andy Lutomirski's message of "Thu, 22 Aug 2013 11:39:15 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@amacapital.net> writes:

> This is a security bug.
>
> The follow-up will fix nsproxy to discourage this type of issue from
> happening again.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
>  net/core/scm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/scm.c b/net/core/scm.c
> index 03795d0..b4da80b 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -54,7 +54,7 @@ static __inline__ int scm_check_creds(struct ucred *creds)
>  		return -EINVAL;
>  
>  	if ((creds->pid == task_tgid_vnr(current) ||
> -	     ns_capable(current->nsproxy->pid_ns->user_ns, CAP_SYS_ADMIN)) &&
> +	     ns_capable(task_active_pid_ns(current)->user_ns, CAP_SYS_ADMIN)) &&
>  	    ((uid_eq(uid, cred->uid)   || uid_eq(uid, cred->euid) ||
>  	      uid_eq(uid, cred->suid)) || nsown_capable(CAP_SETUID)) &&
>  	    ((gid_eq(gid, cred->gid)   || gid_eq(gid, cred->egid) ||
