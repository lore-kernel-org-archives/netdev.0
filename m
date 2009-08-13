From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/3] SELinux: add selinux_kernel_module_request
Date: Thu, 13 Aug 2009 13:43:59 -0500
Message-ID: <20090813184359.GB8391@us.ibm.com>
References: <20090813134451.29186.41664.stgit@paris.rdu.redhat.com> <20090813134502.29186.7938.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	sds@tycho.nsa.gov, davem@davemloft.net,
	shemminger@linux-foundation.org, kees@ubuntu.com,
	morgan@kernel.org, casey@schaufler-ca.com, dwalsh@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090813134502.29186.7938.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric Paris (eparis@redhat.com):
> This patch adds a new selinux hook so SELinux can arbitrate if a given
> process should be allowed to trigger a request for the kernel to try to
> load a module.  This is a different operation than a process trying to load
> a module itself, which is already protected by CAP_SYS_MODULE.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: Serge Hallyn <serue@us.ibm.com>

> ---
> 
>  security/selinux/hooks.c                     |    6 ++++++
>  security/selinux/include/av_perm_to_string.h |    1 +
>  security/selinux/include/av_permissions.h    |    1 +
>  3 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 38afca9..b0d72f1 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -3296,6 +3296,11 @@ static int selinux_kernel_create_files_as(struct cred *new, struct inode *inode)
>  	return 0;
>  }
> 
> +static int selinux_kernel_module_request(void)
> +{
> +	return task_has_system(current, SYSTEM__MODULE_REQUEST);
> +}
> +
>  static int selinux_task_setpgid(struct task_struct *p, pid_t pgid)
>  {
>  	return current_has_perm(p, PROCESS__SETPGID);
> @@ -5457,6 +5462,7 @@ static struct security_operations selinux_ops = {
>  	.cred_prepare =			selinux_cred_prepare,
>  	.kernel_act_as =		selinux_kernel_act_as,
>  	.kernel_create_files_as =	selinux_kernel_create_files_as,
> +	.kernel_module_request =	selinux_kernel_module_request,
>  	.task_setpgid =			selinux_task_setpgid,
>  	.task_getpgid =			selinux_task_getpgid,
>  	.task_getsid =			selinux_task_getsid,
> diff --git a/security/selinux/include/av_perm_to_string.h b/security/selinux/include/av_perm_to_string.h
> index 31df1d7..2b683ad 100644
> --- a/security/selinux/include/av_perm_to_string.h
> +++ b/security/selinux/include/av_perm_to_string.h
> @@ -107,6 +107,7 @@
>     S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_READ, "syslog_read")
>     S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_MOD, "syslog_mod")
>     S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_CONSOLE, "syslog_console")
> +   S_(SECCLASS_SYSTEM, SYSTEM__MODULE_REQUEST, "module_request")
>     S_(SECCLASS_CAPABILITY, CAPABILITY__CHOWN, "chown")
>     S_(SECCLASS_CAPABILITY, CAPABILITY__DAC_OVERRIDE, "dac_override")
>     S_(SECCLASS_CAPABILITY, CAPABILITY__DAC_READ_SEARCH, "dac_read_search")
> diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
> index 0b41ad5..0546d61 100644
> --- a/security/selinux/include/av_permissions.h
> +++ b/security/selinux/include/av_permissions.h
> @@ -530,6 +530,7 @@
>  #define SYSTEM__SYSLOG_READ                       0x00000002UL
>  #define SYSTEM__SYSLOG_MOD                        0x00000004UL
>  #define SYSTEM__SYSLOG_CONSOLE                    0x00000008UL
> +#define SYSTEM__MODULE_REQUEST                    0x00000010UL
>  #define CAPABILITY__CHOWN                         0x00000001UL
>  #define CAPABILITY__DAC_OVERRIDE                  0x00000002UL
>  #define CAPABILITY__DAC_READ_SEARCH               0x00000004UL
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
