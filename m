From: Jeff Garzik <jeff@garzik.org>
Subject: Re: small forcedeth WoL fix
Date: Wed, 13 Jun 2007 16:38:42 -0400
Message-ID: <467055D2.4010205@garzik.org>
References: <20070601172217.686a0d5e@mann-lx.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Tim Mann <mann@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39593 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbXFMUiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:38:46 -0400
In-Reply-To: <20070601172217.686a0d5e@mann-lx.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Mann wrote:
> I happened to notice that a system with an NVidia NIC using the
> forcedeth driver won't wake-on-LAN if the interface was in promiscuous
> mode when you power off.  By experiment, it looks like
> the hardware needs to have NvRegPacketFilterFlags set to
> NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR (i.e., receive unicast packets to my
> address) in order for WoL to work.  At any rate, the attached patch
> fixes the problem for me.
> 
> 
> 
> ------------------------------------------------------------------------
> 
> --- forcedeth-git-netdev.c	2007-06-01 16:43:19.971507000 -0700
> +++ forcedeth-git-netdev-fixed.c	2007-06-01 16:46:53.389713000 -0700
> @@ -4830,8 +4830,10 @@
>  
>  	drain_ring(dev);
>  
> -	if (np->wolenabled)
> +	if (np->wolenabled) {
> +		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
>  		nv_start_rx(dev);
> +	}

Please resend as a proper Linux patch[1], apply-able using "patch -sp1", 
and including a signed-off-by line.

NVIDIA says the patch looks OK.

	Jeff


[1] Documentation/SubmittingPatches or 
http://linux.yyz.us/patch-format.html
