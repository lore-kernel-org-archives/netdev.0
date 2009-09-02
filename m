From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 5/5] net: file_operations should be const
Date: Wed, 02 Sep 2009 10:55:11 +0200
Message-ID: <1251881711.2829.0.camel@sortiz-mobl>
References: <20090902052500.808557262@vyatta.com>
	 <20090902052538.601908379@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51835 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbZIBIxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 04:53:12 -0400
In-Reply-To: <20090902052538.601908379@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-01 at 22:25 -0700, Stephen Hemminger wrote:
> plain text document attachment (const-file-ops.patch)
> All instances of file_operations should be const.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
For the IrDA parts:
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> ---
>  net/ipv6/ip6mr.c                        |    4 ++--
>  net/irda/irnet/irnet_ppp.h              |    2 +-
>  net/irda/irproc.c                       |   14 +++++++-------
>  net/key/af_key.c                        |    2 +-
>  net/mac80211/rc80211_minstrel_debugfs.c |    2 +-
>  net/mac80211/rc80211_pid_debugfs.c      |    2 +-
>  net/xfrm/xfrm_proc.c                    |    2 +-
>  7 files changed, 14 insertions(+), 14 deletions(-)
> 
> --- a/net/ipv6/ip6mr.c	2009-09-01 22:06:18.049861877 -0700
> +++ b/net/ipv6/ip6mr.c	2009-09-01 22:06:45.101130517 -0700
> @@ -217,7 +217,7 @@ static int ip6mr_vif_open(struct inode *
>  			    sizeof(struct ipmr_vif_iter));
>  }
>  
> -static struct file_operations ip6mr_vif_fops = {
> +static const struct file_operations ip6mr_vif_fops = {
>  	.owner	 = THIS_MODULE,
>  	.open    = ip6mr_vif_open,
>  	.read    = seq_read,
> @@ -341,7 +341,7 @@ static int ipmr_mfc_open(struct inode *i
>  			    sizeof(struct ipmr_mfc_iter));
>  }
>  
> -static struct file_operations ip6mr_mfc_fops = {
> +static const struct file_operations ip6mr_mfc_fops = {
>  	.owner	 = THIS_MODULE,
>  	.open    = ipmr_mfc_open,
>  	.read    = seq_read,
> --- a/net/irda/irnet/irnet_ppp.h	2009-09-01 22:06:18.066775983 -0700
> +++ b/net/irda/irnet/irnet_ppp.h	2009-09-01 22:07:01.768232028 -0700
> @@ -95,7 +95,7 @@ static int
>  /**************************** VARIABLES ****************************/
>  
>  /* Filesystem callbacks (to call us) */
> -static struct file_operations irnet_device_fops =
> +static const struct file_operations irnet_device_fops =
>  {
>  	.owner		= THIS_MODULE,
>  	.read		= dev_irnet_read,
> --- a/net/irda/irproc.c	2009-09-01 22:06:18.083862409 -0700
> +++ b/net/irda/irproc.c	2009-09-01 22:07:33.742884934 -0700
> @@ -34,21 +34,21 @@
>  #include <net/irda/irlap.h>
>  #include <net/irda/irlmp.h>
>  
> -extern struct file_operations discovery_seq_fops;
> -extern struct file_operations irlap_seq_fops;
> -extern struct file_operations irlmp_seq_fops;
> -extern struct file_operations irttp_seq_fops;
> -extern struct file_operations irias_seq_fops;
> +extern const struct file_operations discovery_seq_fops;
> +extern const struct file_operations irlap_seq_fops;
> +extern const struct file_operations irlmp_seq_fops;
> +extern const struct file_operations irttp_seq_fops;
> +extern const struct file_operations irias_seq_fops;
>  
>  struct irda_entry {
>  	const char *name;
> -	struct file_operations *fops;
> +	const struct file_operations *fops;
>  };
>  
>  struct proc_dir_entry *proc_irda;
>  EXPORT_SYMBOL(proc_irda);
>  
> -static struct irda_entry irda_dirs[] = {
> +static const struct irda_entry irda_dirs[] = {
>  	{"discovery",	&discovery_seq_fops},
>  	{"irttp",	&irttp_seq_fops},
>  	{"irlmp",	&irlmp_seq_fops},
> --- a/net/key/af_key.c	2009-09-01 22:06:18.103861872 -0700
> +++ b/net/key/af_key.c	2009-09-01 22:07:53.008956985 -0700
> @@ -3718,7 +3718,7 @@ static int pfkey_seq_open(struct inode *
>  			    sizeof(struct seq_net_private));
>  }
>  
> -static struct file_operations pfkey_proc_ops = {
> +static const struct file_operations pfkey_proc_ops = {
>  	.open	 = pfkey_seq_open,
>  	.read	 = seq_read,
>  	.llseek	 = seq_lseek,
> --- a/net/mac80211/rc80211_minstrel_debugfs.c	2009-09-01 22:06:18.119862498 -0700
> +++ b/net/mac80211/rc80211_minstrel_debugfs.c	2009-09-01 22:08:22.747241542 -0700
> @@ -139,7 +139,7 @@ minstrel_stats_release(struct inode *ino
>  	return 0;
>  }
>  
> -static struct file_operations minstrel_stat_fops = {
> +static const struct file_operations minstrel_stat_fops = {
>  	.owner = THIS_MODULE,
>  	.open = minstrel_stats_open,
>  	.read = minstrel_stats_read,
> --- a/net/mac80211/rc80211_pid_debugfs.c	2009-09-01 22:06:18.135862300 -0700
> +++ b/net/mac80211/rc80211_pid_debugfs.c	2009-09-01 22:08:28.843245757 -0700
> @@ -198,7 +198,7 @@ static ssize_t rate_control_pid_events_r
>  
>  #undef RC_PID_PRINT_BUF_SIZE
>  
> -static struct file_operations rc_pid_fop_events = {
> +static const struct file_operations rc_pid_fop_events = {
>  	.owner = THIS_MODULE,
>  	.read = rate_control_pid_events_read,
>  	.poll = rate_control_pid_events_poll,
> --- a/net/xfrm/xfrm_proc.c	2009-09-01 22:06:18.169862213 -0700
> +++ b/net/xfrm/xfrm_proc.c	2009-09-01 22:08:48.707830315 -0700
> @@ -60,7 +60,7 @@ static int xfrm_statistics_seq_open(stru
>  	return single_open_net(inode, file, xfrm_statistics_seq_show);
>  }
>  
> -static struct file_operations xfrm_statistics_seq_fops = {
> +static const struct file_operations xfrm_statistics_seq_fops = {
>  	.owner	 = THIS_MODULE,
>  	.open	 = xfrm_statistics_seq_open,
>  	.read	 = seq_read,
> 

