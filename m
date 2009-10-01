From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 1 Oct 2009 09:21:00 -0700
Message-ID: <20091001092100.14ea024b@s6510>
References: <200910011916.40908.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Cosmin Ratiu <cratiu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52221 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbZJAQU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 12:20:57 -0400
In-Reply-To: <200910011916.40908.cratiu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2009 19:16:40 +0300
Cosmin Ratiu <cratiu@ixiacom.com> wrote:

> Hello,
> 
> This is a patch that adds a sysctl to control the sending of the Target Link 
> Layer Address Option (TLLAO) with Neighbor Advertisements responding to 
> unicast NS. The patch was made for kernel 2.6.7 (yes it is ancient), but the 
> code is similar with the current kernel and I can rework it if you want it in.
> 
> RFC 2461, page 24 suggests that this option should be included with NAs to 
> avoid a race with the sender clearing its cache after sending an unicast NS, 
> but before receiving a NA.
> 
> It seems there are some Juniper routers (MX series) that expect this option to 
> be included with all NAs.
> 
> Another solution is to always send this option, as it has little overhead.
> 
> Please let me know what you think,
> Cosmin.
> 
> Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
> --- //packages/linux_2.6.7/main/src/include/linux/sysctl.h
> +++ /home/z/w1/packages/linux_2.6.7/main/src/include/linux/sysctl.h
> @@ -444,6 +444,7 @@                                                
>         NET_IPV6_IP6FRAG_TIME=23,                                  
>         NET_IPV6_IP6FRAG_SECRET_INTERVAL=24,                       
>         NET_IPV6_MLD_MAX_MSF=25,                                   
> +       NET_IPV6_NDISC_FORCE_TLLAO=26,                             

Since numbered sysctl values are deprecated, can you use CTL_UNNUMBERED
to avoid having to add yet another value?
