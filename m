From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC 3/9] snet: introduce security/snet, Makefile and Kconfig
 changes
Date: Mon, 4 Jan 2010 12:39:43 -0600
Message-ID: <20100104183943.GB6034@us.ibm.com>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
 <1262437456-24476-4-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1262437456-24476-4-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Samir Bellabes (sam@synack.fr):
> this patch creates a entry in folder security/ and adds Kconfig and Makefile
> 
> Signed-off-by: Samir Bellabes <sam@synack.fr>
> ---
>  security/Kconfig       |    1 +
>  security/Makefile      |    2 ++
>  security/snet/Kconfig  |   22 ++++++++++++++++++++++
>  security/snet/Makefile |   13 +++++++++++++
>  4 files changed, 38 insertions(+), 0 deletions(-)
>  create mode 100644 security/snet/Kconfig
>  create mode 100644 security/snet/Makefile
> 
> diff --git a/security/Kconfig b/security/Kconfig
> index 226b955..48e8fee 100644
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -140,6 +140,7 @@ config LSM_MMAP_MIN_ADDR
>  source security/selinux/Kconfig
>  source security/smack/Kconfig
>  source security/tomoyo/Kconfig
> +source security/snet/Kconfig
> 
>  source security/integrity/ima/Kconfig
> 
> diff --git a/security/Makefile b/security/Makefile
> index bb44e35..0870dd0 100644
> --- a/security/Makefile
> +++ b/security/Makefile
> @@ -6,6 +6,7 @@ obj-$(CONFIG_KEYS)			+= keys/
>  subdir-$(CONFIG_SECURITY_SELINUX)	+= selinux
>  subdir-$(CONFIG_SECURITY_SMACK)		+= smack
>  subdir-$(CONFIG_SECURITY_TOMOYO)        += tomoyo
> +subdir-$(CONFIG_SECURITY_SNET)		+= snet
> 
>  # always enable default capabilities
>  obj-y		+= commoncap.o min_addr.o
> @@ -18,6 +19,7 @@ obj-$(CONFIG_SECURITY_SELINUX)		+= selinux/built-in.o
>  obj-$(CONFIG_SECURITY_SMACK)		+= smack/built-in.o
>  obj-$(CONFIG_AUDIT)			+= lsm_audit.o
>  obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/built-in.o
> +obj-$(CONFIG_SECURITY_SNET)		+= snet/built-in.o
>  obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
> 
>  # Object integrity file lists
> diff --git a/security/snet/Kconfig b/security/snet/Kconfig
> new file mode 100644
> index 0000000..e1516a1
> --- /dev/null
> +++ b/security/snet/Kconfig
> @@ -0,0 +1,22 @@
> +#
> +# snet
> +#
> +
> +config SECURITY_SNET
> +	bool "snet - Security for NETwork syscalls"
> +	depends on SECURITY_NETWORK && IPV6

Why depend on IPV6?

> +	default n
> +	---help---
> +	Provide a generic netlink that reports networking's syscalls
> +	to userspace

And also wait for userspace to decide whether to authorize the
syscall, right?  'report on' is very different.

> +
> +config SECURITY_SNET_DEBUG
> +       bool "snet debug messages"
> +       depends on SECURITY_SNET
> +       ---help---
> +       Only use if you are hacking snet.
> +
> +       This toggles the debugging outputs, by setting the parameter snet_debug
> +       to 0 or 1 at boot.
> +
> +       Just say N
> diff --git a/security/snet/Makefile b/security/snet/Makefile
> new file mode 100644
> index 0000000..ee6bd83
> --- /dev/null
> +++ b/security/snet/Makefile
> @@ -0,0 +1,13 @@
> +#
> +# Makefile for building the Security Network Events module.
> +#
> +obj-$(CONFIG_SECURITY_SNET) :=  snet.o
> +
> +snet-y := snet_event.o \
> +	  snet_netlink.o \
> +	  snet_verdict.o \
> +	  snet_hooks.o \
> +	  snet_core.o \
> +	  snet_utils.o
> +
> +EXTRA_CFLAGS += -Isecurity/snet/include
> -- 
> 1.6.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
