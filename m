From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 1/1][IPV6] resend:  remove duplicate call to proc_net_remove
Date: Tue, 30 Oct 2007 14:53:53 -0600
Message-ID: <m1k5p4l3xa.fsf@ebiederm.dsl.xmission.com>
References: <20071030162344.297260466@mai.toulouse-stg.fr.ibm.com>
	<20071030162450.257974469@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39741 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbXJ3UzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 16:55:08 -0400
In-Reply-To: <20071030162450.257974469@mai.toulouse-stg.fr.ibm.com> (Daniel
	Lezcano's message of "Tue, 30 Oct 2007 17:23:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> The file /proc/net/if_inet6 is removed twice.
> First time in:
>         inet6_exit
>              ->addrconf_cleanup
> And followed a few lines after by:
>         inet6_exit
>              -> if6_proc_exit
>
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Looks like a good clean up to me.




> ---
>  net/ipv6/addrconf.c |    4 ----
>  1 file changed, 4 deletions(-)
>
> Index: net-2.6/net/ipv6/addrconf.c
> ===================================================================
> --- net-2.6.orig/net/ipv6/addrconf.c
> +++ net-2.6/net/ipv6/addrconf.c
> @@ -4288,8 +4288,4 @@ void __exit addrconf_cleanup(void)
>  	del_timer(&addr_chk_timer);
>  
>  	rtnl_unlock();
> -
> -#ifdef CONFIG_PROC_FS
> -	proc_net_remove(&init_net, "if_inet6");
> -#endif
>  }
>
> -- 
