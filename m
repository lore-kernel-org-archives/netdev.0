From: bert hubert <bert.hubert@netherlabs.nl>
Subject: tested: Re: [PATCH] tcp: make cubic the default
Date: Sat, 23 Sep 2006 13:14:34 +0200
Message-ID: <20060923111434.GA10254@outpost.ds9a.nl>
References: <20060919214304.GB13543@outpost.ds9a.nl> <20060919.154435.102044066.davem@davemloft.net> <20060919160202.23390471@localhost.localdomain> <20060919.160441.66322371.davem@davemloft.net> <20060919162355.3a22fec1@localhost.localdomain> <20060920081704.GA1812@outpost.ds9a.nl> <20060920133258.36ff42ce@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:5826 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1750738AbWIWLOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 07:14:36 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060920133258.36ff42ce@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

I've applied both of your patches
(http://marc.theaimsgroup.com/?l=linux-netdev&m=115878447914612&w=2
and 
http://marc.theaimsgroup.com/?l=linux-netdev&m=115878448125216&w=2
) and tried to break them, but it now appears to do the right thing in all
cases, even when malforming the .config by hand, a 'make oldconfig' restores
sanity.

Reno is chosen if none of the non-scary congestion avoidance algorithms are
available, and the default for when they are are as you intended.

I've testbooted the resulting kernel and everything appears to work as
desired, the proper TCP gets chosen, loading other ones does not change the
default, but does make them available.

Unloading the module containing the configured policy sets the policy to
'cubic', which is probably the next entry in the policy list.

All in all, this final iteration of the congestion selection patches appears
to do the job!

Davem, I'd recommend both patches for merging.

	Bert

On Wed, Sep 20, 2006 at 01:32:58PM -0700, Stephen Hemminger wrote:
> Change default congestion control used from BIC to the newer CUBIC
> which it the successor to BIC but has better properties over long delay links.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> ---
>  net/ipv4/Kconfig |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> --- net-test.orig/net/ipv4/Kconfig	2006-09-20 12:22:06.000000000 -0700
> +++ net-test/net/ipv4/Kconfig	2006-09-20 13:31:21.000000000 -0700
> @@ -454,7 +454,7 @@
>  	  modules.
>  
>  	  Nearly all users can safely say no here, and a safe default
> -	  selection will be made (BIC-TCP with new Reno as a fallback).
> +	  selection will be made (CUBIC with new Reno as a fallback).
>  
>  	  If unsure, say N.
>  
> @@ -462,7 +462,7 @@
>  
>  config TCP_CONG_BIC
>  	tristate "Binary Increase Congestion (BIC) control"
> -	default y
> +	default m
>  	---help---
>  	BIC-TCP is a sender-side only change that ensures a linear RTT
>  	fairness under large windows while offering both scalability and
> @@ -476,7 +476,7 @@
>  
>  config TCP_CONG_CUBIC
>  	tristate "CUBIC TCP"
> -	default m
> +	default y
>  	---help---
>  	This is version 2.0 of BIC-TCP which uses a cubic growth function
>  	among other techniques.
> @@ -573,7 +573,7 @@
>  
>  choice
>  	prompt "Default TCP congestion control"
> -	default DEFAULT_BIC
> +	default DEFAULT_CUBIC
>  	help
>  	  Select the TCP congestion control that will be used by default
>  	  for all connections.
> @@ -600,7 +600,7 @@
>  
>  endif
>  
> -config TCP_CONG_BIC
> +config TCP_CONG_CUBIC
>  	tristate
>  	depends on !TCP_CONG_ADVANCED
>  	default y
> @@ -613,7 +613,7 @@
>  	default "vegas" if DEFAULT_VEGAS
>  	default "westwood" if DEFAULT_WESTWOOD
>  	default "reno" if DEFAULT_RENO
> -	default "bic"
> +	default "cubic"
>  
>  source "net/ipv4/ipvs/Kconfig"
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> !DSPAM:4511a594269391527717022!
> 

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
