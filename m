From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC v3 06/22] landlock: Add LSM hooks
Date: Wed, 19 Oct 2016 17:19:06 +0200
Message-ID: <20161019151906.GC22003@pox.localdomain>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-7-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Mack <daniel@zonque.org>,
	David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
	Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
	linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, cgroups@vger.kernel.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-4949-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <20160914072415.26021-7-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On 09/14/16 at 09:23am, Mickaël Salaün wrote:
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 9aa01d9d3d80..36c3e482239c 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -85,6 +85,8 @@ enum bpf_arg_type {
>  
>  	ARG_PTR_TO_CTX,		/* pointer to context */
>  	ARG_ANYTHING,		/* any (initialized) argument is ok */
> +
> +	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */

This should go into patch 7 I guess?

> +void __init landlock_add_hooks(void)
> +{
> +	pr_info("landlock: Becoming ready for sandboxing\n");
> +	security_add_hooks(landlock_hooks, ARRAY_SIZE(landlock_hooks));
> +}

Can we add the hooks when we load the first BPF program for a hook? That
would also allow to not make this conditional on a new config option
which all all distros have to enable anyway.

I would really like to see this patch split into the LSM part which
allows running BPF progs at LSM and your specific sandboxing use case
which requires the new BPF helpers, new reg type, etc.
