From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH v3 04/11] syslog_ns: make syslog handling per namespace
Date: Wed, 7 Aug 2013 20:52:43 +0200
Message-ID: <1375901563.2644.84.camel@deadeye.wl.decadent.org.uk>
References: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
	<1375861035-24320-5-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375861035-24320-5-git-send-email-rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 15:37 +0800, Rui Xiang wrote:
> This patch makes syslog buf and other fields per
> namespace.
> 
> Here use ns->log_buf(log_buf_len, logbuf_lock,
> log_first_seq, logbuf_lock, and so on) fields
> instead of global ones to handle syslog.
[...]
> --- a/kernel/printk.c
> +++ b/kernel/printk.c
[...]
>  }
>  
> -#ifdef CONFIG_SECURITY_DMESG_RESTRICT
> -int dmesg_restrict = 1;
> -#else
> -int dmesg_restrict;
> -#endif
> -
> -static int syslog_action_restricted(int type)
> +static int syslog_action_restricted(int type,
> +			struct syslog_namespace *ns)
>  {
> -	if (dmesg_restrict)
> +	if (ns->dmesg_restrict)
>  		return 1;
>  	/*
>  	 * Unless restricted, we allow "read all" and "get buffer size"
[...]

I don't think this should be a per-namespace setting.  And it certainly
should not be possible for child namespaces to disable dmesg_restrict if
it is enabled by a parent namespace.

In later patches, it appears to be copied into child namespaces but not
made visible or controllable there.  So if an administrator enables
dmesg_restrict in the initial syslog namespace after another syslog
namespace has been created, she won't be able to tell that it is still
disabled in that other namespace.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
