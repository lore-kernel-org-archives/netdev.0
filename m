From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH 25/59] sysctl: C99 convert arch/frv/kernel/pm.c
Date: Wed, 17 Jan 2007 20:14:17 +0300
Message-ID: <45AE5969.8030603@sw.ru>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com> <11689656443582-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "<Andrew Morton" <akpm@osdl.org>, James.Bottomley@SteelEye.com,
	linux-mips@linux-mips.org, linux-parport@lists.infradead.org,
	minyard@acm.org, rtc-linux@googlegroups.com, clemens@ladisch.de,
	heiko.carstens@de.ibm.com, xfs@oss.sgi.com,
	linuxppc-dev@ozlabs.org, paulus@samba.org,
	openipmi-developer@lists.sourceforge.net, linux-390@vm.marist.edu,
	schwidefsky@de.ibm.com, tim@cyberelk.net,
	codalist@TELEMANN.coda.cs.cmu.edu, a.zummo@towertech.it,
	tony.luck@intel.com, vojtech@suse.cz, linux-scsi@vger.kernel.org,
	xfs-masters@oss.sgi.com, linux-ntfs-dev@lists.sourceforge.net,
	netdev@vger.kernel.org, aia21@cantab.net, aharkes@cs.cmu.edu,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	mark.fasheh@oracle.com, coda@cs.cmu.edu, lethal@linux-sh.org,
	kurt.hackel@oracle.com, containers@lists.osdl.org,
	linux390@de.ibm.com, philb@gnu.org, andrea@suse.de,
	linuxsh-shmedia-dev@lists.sour
Return-path: <linux-mips-bounce@linux-mips.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <11689656443582-git-send-email-ebiederm@xmission.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

another small minor note.

> From: Eric W. Biederman <ebiederm@xmission.com> - unquoted
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  arch/frv/kernel/pm.c |   50 +++++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 43 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/frv/kernel/pm.c b/arch/frv/kernel/pm.c
> index c1840d6..aa50333 100644
> --- a/arch/frv/kernel/pm.c
> +++ b/arch/frv/kernel/pm.c
> @@ -401,17 +401,53 @@ static int cm_sysctl(ctl_table *table, int __user *name, int nlen,
>  
>  static struct ctl_table pm_table[] =
>  {
> -	{CTL_PM_SUSPEND, "suspend", NULL, 0, 0200, NULL, &sysctl_pm_do_suspend},
> -	{CTL_PM_CMODE, "cmode", &clock_cmode_current, sizeof(int), 0644, NULL, &cmode_procctl, &cmode_sysctl, NULL},
> -	{CTL_PM_P0, "p0", &clock_p0_current, sizeof(int), 0644, NULL, &p0_procctl, &p0_sysctl, NULL},
> -	{CTL_PM_CM, "cm", &clock_cm_current, sizeof(int), 0644, NULL, &cm_procctl, &cm_sysctl, NULL},
> -	{0}
> +	{
> +		.ctl_name	= CTL_PM_SUSPEND,
> +		.procname	= "suspend",
> +		.data		= NULL,
> +		.maxlen		= 0,
> +		.mode		= 0200,
> +		.proc_handler	= &sysctl_pm_do_suspend,
> +	},
> +	{
> +		.ctl_name	= CTL_PM_CMODE,
> +		.procname	= "cmode",
> +		.data		= &clock_cmode_current,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &cmode_procctl,
> +		.strategy	= &cmode_sysctl,
> +	},
> +	{
> +		.ctl_name	= CTL_PM_P0,
> +		.procname	= "p0",
> +		.data		= &clock_p0_current,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &p0_procctl,
> +		.strategy	= &p0_sysctl,
> +	},
> +	{
> +		.ctl_name	= CTL_PM_CM,
> +		.procname	= "cm",
> +		.data		= &clock_cm_current,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &cm_procctl,
> +		.strategy	= &cm_sysctl,
> +	},
> +	{ .ctl_name = 0}
in next patch (26/59) you write just "{ }". .ctl_name = 0 not required here.


>  };
>  
>  static struct ctl_table pm_dir_table[] =
>  {
> -	{CTL_PM, "pm", NULL, 0, 0555, pm_table},
> -	{0}
> +	{
> +		.ctl_name	= CTL_PM,
> +		.procname	= "pm",
> +		.mode		= 0555,
> +		.child		= pm_table,
> +	},
> +	{ .ctl_name = 0}
>  };
>  
>  /*
