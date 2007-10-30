From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] Convert /proc/net/ipv6_route to seq_file interface
Date: Tue, 30 Oct 2007 08:30:43 -0700
Message-ID: <20071030083043.47f5def3@freepuppy.rosehill>
References: <20071030131147.GA6210@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36945 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754714AbXJ3Pb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 11:31:56 -0400
In-Reply-To: <20071030131147.GA6210@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Oct 2007 16:11:47 +0300
Alexey Dobriyan <adobriyan@sw.ru> wrote:
>  
> +static const struct file_operations ipv6_route_proc_fops = {
> +	.open		= ipv6_route_open,
> +	.read		= seq_read,
> +	.llseek		= seq_lseek,
> +	.release	= single_release,
> +};
> +

This needs
	.owner		= THIS_MODULE,


>
>  static int rt6_stats_seq_show(struct seq_file *seq, void *v)
>  {
>  	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
> @@ -2499,9 +2477,11 @@ void __init ip6_route_init(void)
>  
>  	fib6_init();
>  #ifdef 	CONFIG_PROC_FS
> -	p = proc_net_create(&init_net, "ipv6_route", 0, rt6_proc_info);
> -	if (p)
> +	p = create_proc_entry("ipv6_route", 0, init_net.proc_net);
> +	if (p) {
>  		p->owner = THIS_MODULE;
> +		p->proc_fops = &ipv6_route_proc_fops;
> +	}
>  
>  	proc_net_fops_create(&init_net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
>  #endif
> 

Use proc_net_fops_create()
	proc_net_fops_create(&init_net, "ipv6_route", S_IRUGO, &ipv6_route_proc_fops)


You can get rid of #ifdef since proc_net_fops_create stub does correct thing
if PROC_FS is not configured.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
