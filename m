From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 02/12] trace: Make trace_hwlat timestamp
	y2038 safe
Date: Fri, 7 Apr 2017 21:30:11 -0400
Message-ID: <20170407213011.36e29f42@gandalf.local.home>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-3-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bfields@fieldses.org, clm@fb.com, linux-mtd@lists.infradead.org,
	dushistov@mail.ru, jlayton@poochiereds.net,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-cifs@vger.kernel.org, paul@paul-moore.com,
	y2038@lists.linaro.org, mingo@redhat.com, jsimmons@infradead.org,
	arnd@arndb.de, oleg.drokin@intel.com, john.stultz@linaro.org,
	viro@zeniv.linux.org.uk, dsterba@suse.com, jaegeuk@kernel.org,
	tglx@linutronix.de, andreas.dilger@intel.com, jbacik@fb.com,
	gregkh@linuxfoundation.org, samba-technical@lists.samba.org,
	linux-kernel@vger.kernel.org, eparis@redhat.com,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-security-module@vger.kernel.org, linux-audit@redhat.com,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1491613030-11599-3-git-send-email-deepa.kernel@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
	<mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
	<mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri,  7 Apr 2017 17:57:00 -0700
Deepa Dinamani <deepa.kernel@gmail.com> wrote:

> struct timespec is not y2038 safe on 32 bit machines
> and needs to be replaced by struct timespec64
> in order to represent times beyond year 2038 on such
> machines.
> 
> Fix all the timestamp representation in struct trace_hwlat
> and all the corresponding implementations.
> 

> diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
> index 02a4aeb..08f9bab 100644
> --- a/kernel/trace/trace_output.c
> +++ b/kernel/trace/trace_output.c
> @@ -4,7 +4,6 @@
>   * Copyright (C) 2008 Red Hat Inc, Steven Rostedt <srostedt@redhat.com>
>   *
>   */
> -
>  #include <linux/module.h>
>  #include <linux/mutex.h>
>  #include <linux/ftrace.h>
> @@ -1161,11 +1160,11 @@ trace_hwlat_print(struct trace_iterator *iter, int flags,
>  
>  	trace_assign_type(field, entry);
>  
> -	trace_seq_printf(s, "#%-5u inner/outer(us): %4llu/%-5llu ts:%ld.%09ld",
> +	trace_seq_printf(s, "#%-5u inner/outer(us): %4llu/%-5llu ts:%lld.%09ld",
>  			 field->seqnum,
>  			 field->duration,
>  			 field->outer_duration,
> -			 field->timestamp.tv_sec,
> +			 (long long)field->timestamp.tv_sec,

Refresh my memory. We need the cast because on 64 bit boxes
timestamp.tv_sec is just a long?

Other than that.

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve

>  			 field->timestamp.tv_nsec);
>  
>  	if (field->nmi_count) {
> @@ -1195,10 +1194,10 @@ trace_hwlat_raw(struct trace_iterator *iter, int flags,
>  
>  	trace_assign_type(field, iter->ent);
>  
> -	trace_seq_printf(s, "%llu %lld %ld %09ld %u\n",
> +	trace_seq_printf(s, "%llu %lld %lld %09ld %u\n",
>  			 field->duration,
>  			 field->outer_duration,
> -			 field->timestamp.tv_sec,
> +			 (long long)field->timestamp.tv_sec,
>  			 field->timestamp.tv_nsec,
>  			 field->seqnum);
>  


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
