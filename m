From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/2] Rename nsproxy.pid_ns to
	nsproxy.pid_ns_for_children
Date: Thu, 22 Aug 2013 20:56:05 +0200
Message-ID: <20130822185605.GA24890@redhat.com>
References: <cover.1377196394.git.luto@amacapital.net> <a5db0606160dbd1412828be0d91a4a115a84abf6.1377196394.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, security@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a5db0606160dbd1412828be0d91a4a115a84abf6.1377196394.git.luto@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22, Andy Lutomirski wrote:
>
> nsproxy.pid_ns is *not* the task's pid namespace.  The name should clarify
> that.
>
> This makes it more obvious that setns on a pid namespace is weird --
> it won't change the pid namespace shown in procfs.
>
> ...
>
> + * The pid namespace is an exception -- it's accessed using
> + * task_active_pid_ns.  The pid namespace here is the
> + * namespace that children will use.
> + *
>   * 'count' is the number of tasks holding a reference.
>   * The count for each namespace, then, will be the number
>   * of nsproxies pointing to it, not the number of tasks.
> @@ -27,7 +31,7 @@ struct nsproxy {
>  	struct uts_namespace *uts_ns;
>  	struct ipc_namespace *ipc_ns;
>  	struct mnt_namespace *mnt_ns;
> -	struct pid_namespace *pid_ns;
> +	struct pid_namespace *pid_ns_for_children;
>  	struct net 	     *net_ns;

Personally I agree. ->pid_ns is "strange" and it makes sense to
document and make clear the fact that it became the implicit
argument for clone().

Oleg.
