From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] Fix ipchains/ipfw modules
Date: Fri, 24 Sep 2004 12:15:08 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415439FC.10401@conectiva.com.br>
References: <m3fz57915u.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, coreteam@netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m3fz57915u.fsf@averell.firstfloor.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy fixed this in a different way in the "Re: [PATCH] Warn 
people that ipchains and ipfwadm are going away." lkml thread :-)

His explanation:

"Fixed by this patch. The conntrack protocols need ip_ct_log_invalid
which is defined in ip_conntrack_standalone, so ip_conntrack is
loaded automatically before ipchains. This patch moves it over to
ip_conntrack_core."

- Arnaldo

Andi Kleen wrote:
> ipchains didn't load anymore because it had a undefined symbol,
> which was satisfied by ipconntrack. This caused ipconntrack to be
> loaded first by modprobe, but the second ipconntrack init in ipchains
> would fail, causing the ipchains load to fail.
> 
> ipfw had the same problem.
> 
> Declare the missing variable.
> 
> Signed-off-by: Andi Kleen <ak@muc.de>
> 
> diff -u linux/net/ipv4/netfilter/ip_fw_compat.c-IPC linux/net/ipv4/netfilter/ip_fw_compat.c
> --- linux/net/ipv4/netfilter/ip_fw_compat.c-IPC	2004-06-16 14:07:34.000000000 +0200
> +++ linux/net/ipv4/netfilter/ip_fw_compat.c	2004-09-24 15:56:55.000000000 +0200
> @@ -28,6 +28,8 @@
>  
>  static struct firewall_ops *fwops;
>  
> +unsigned int ip_ct_log_invalid;
> +
>  #ifdef CONFIG_IP_VS
>  /* From ip_vs_core.c */
>  extern unsigned int
> 
> 
> 
> 
> 
> 
