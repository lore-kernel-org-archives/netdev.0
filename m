From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 35/59] sysctl: C99 convert ctl_tables in
	arch/powerpc/kernel/idle.c
Date: Wed, 17 Jan 2007 14:16:27 +1100
Message-ID: <1169003787.4778.17.camel@localhost.localdomain>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
	 <11689656593247-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "<Andrew Morton" <akpm@osdl.org>, linux-mips@linux-mips.org,
	linux-parport@lists.infradead.org, heiko.carstens@de.ibm.com,
	ak@suse.de, linuxppc-dev@ozlabs.org, paulus@samba.org,
	aharkes@cs.cmu.edu, schwidefsky@de.ibm.com, tim@cyberelk.net,
	rtc-linux@googlegroups.com, linux-scsi@vger.kernel.org,
	kurt.hackel@oracle.com, coda@cs.cmu.edu, vojtech@suse.cz,
	linuxsh-shmedia-dev@lists.sourceforge.net,
	James.Bottomley@SteelEye.com, clemens@ladisch.de, xfs@oss.sgi.com,
	xfs-masters@oss.sgi.com, andrea@suse.de,
	openipmi-developer@lists.sourceforge.net, linux-390@vm.marist.edu,
	codalist@TELEMANN.coda.cs.cmu.edu, a.zummo@towertech.it,
	tony.luck@intel.com, linux-ntfs-dev@lists.sourceforge.net,
	netdev@vger.kernel.org, aia21@cantab.net,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	lethal@linux-sh.org, containers@lists.osdl.org,
	linux390@de.ibm.com, philb@gnu.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <11689656593247-git-send-email-ebiederm@xmission.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-16 at 09:39 -0700, Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@xmission.com> - unquoted
> 
> This was partially done already and there was no ABI breakage what
> a relief.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

> ---
>  arch/powerpc/kernel/idle.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/idle.c b/arch/powerpc/kernel/idle.c
> index 8994af3..8b27bb1 100644
> --- a/arch/powerpc/kernel/idle.c
> +++ b/arch/powerpc/kernel/idle.c
> @@ -110,11 +110,16 @@ static ctl_table powersave_nap_ctl_table[]={
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec,
>  	},
> -	{ 0, },
> +	{}
>  };
>  static ctl_table powersave_nap_sysctl_root[] = {
> -	{ 1, "kernel", NULL, 0, 0755, powersave_nap_ctl_table, },
> - 	{ 0,},
> +	{
> +		.ctl_name	= CTL_KERN,
> +		.procname	= "kernel",
> +		.mode		= 0755,
> +		.child		= powersave_nap_ctl_table,
> +	},
> +	{}
>  };
>  
>  static int __init
