From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [2.6 patch] make get_proc_net() static
Date: Tue, 22 Jul 2008 23:13:00 +0400
Message-ID: <4886313C.3000200@openvz.org>
References: <20080722172033.GQ14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38558 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbYGVTQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 15:16:45 -0400
In-Reply-To: <20080722172033.GQ14846@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> get_proc_net() can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

Although there are some files in net/ that do not yet use
the seq_file interface and thus may require this function
when netnsizated, hiding this one will force us clean these
files first by switching to use seq_files :)

> ---
> 
>  fs/proc/proc_net.c      |   11 +++++------
>  include/linux/proc_fs.h |    2 --
>  2 files changed, 5 insertions(+), 8 deletions(-)
> 
> 48b48347bed28ecad3c612d2fdffbde73dc98584 
> diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
> index b224a28..7bc296f 100644
> --- a/fs/proc/proc_net.c
> +++ b/fs/proc/proc_net.c
> @@ -27,6 +27,11 @@
>  #include "internal.h"
>  
>  
> +static struct net *get_proc_net(const struct inode *inode)
> +{
> +	return maybe_get_net(PDE_NET(PDE(inode)));
> +}
> +
>  int seq_open_net(struct inode *ino, struct file *f,
>  		 const struct seq_operations *ops, int size)
>  {
> @@ -185,12 +190,6 @@ void proc_net_remove(struct net *net, const char *name)
>  }
>  EXPORT_SYMBOL_GPL(proc_net_remove);
>  
> -struct net *get_proc_net(const struct inode *inode)
> -{
> -	return maybe_get_net(PDE_NET(PDE(inode)));
> -}
> -EXPORT_SYMBOL_GPL(get_proc_net);
> -
>  static __net_init int proc_net_ns_init(struct net *net)
>  {
>  	struct proc_dir_entry *netd, *net_statd;
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index fff1d27..15a9eaf 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -305,8 +305,6 @@ static inline struct net *PDE_NET(struct proc_dir_entry *pde)
>  	return pde->parent->data;
>  }
>  
> -struct net *get_proc_net(const struct inode *inode);
> -
>  struct proc_maps_private {
>  	struct pid *pid;
>  	struct task_struct *task;
> 
> 

