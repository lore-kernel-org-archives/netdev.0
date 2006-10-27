From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 13:43:08 -0400
Message-ID: <4542452C.6050209@psc.edu>
References: <4540F076.70801@psc.edu>	<20061026224407.GA2018@c3po.0xdef.net>	<20061026235256.GB2018@c3po.0xdef.net>	<20061026.170221.99202188.davem@davemloft.net>	<20061027104311.GB3967@c3po.0xdef.net>	<20061027074102.2a6fef4b@localhost.localdomain>	<20061027152157.GB4632@c3po.0xdef.net>	<45422A31.7070806@osdl.org> <20061027103016.3e8514d7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:5847 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1752363AbWJ0Rn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 13:43:29 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061027103016.3e8514d7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think "unfair" is a difficult word.  Unfair to what?  It's true that 
Scalable TCP is unfair to itself in that flows with unequal shares do 
not converge, but it's not clear what its interactions are with other 
congestion control algorithms.  It's not clear to me that it's 
significantly more unfair wrt. reno than BIC, etc.  "Known to be broken" 
might be more correct language. :)

One thought would be to use a module parameter that sets one bit of 
state: allow unprivileged use.  Each module could have a sensible 
default value.

   -John


Stephen Hemminger wrote:
> My proposed method restricting TCP choices to fair algorithms.
> This a net wide, not system wide issue, it should not be done
> by kernel policy choice (capability), but by a build choice.
> 
> --- sky2.orig/net/ipv4/Kconfig	2006-10-27 10:10:47.000000000 -0700
> +++ sky2/net/ipv4/Kconfig	2006-10-27 10:15:56.000000000 -0700
> @@ -470,6 +470,16 @@
>  
>  if TCP_CONG_ADVANCED
>  
> +config TCP_CONG_UNFAIR
> +        bool "Allow unfair congestion control algorithms"
> +	depends on EXPERIMENTAL
> +        ---help---
> +	  Some of the congestion control algorithms are for testing
> +	  and research purposes and should not deployed on public
> +	  networks because of the possiblity of unfair behavior.
> +	  These algorithms may be useful for future development
> +	  or comparison purposes.
> +
>  config TCP_CONG_BIC
>  	tristate "Binary Increase Congestion (BIC) control"
>  	default m
> @@ -551,7 +561,7 @@
>  
>  config TCP_CONG_SCALABLE
>  	tristate "Scalable TCP"
> -	depends on EXPERIMENTAL
> +	depends on TCP_CONG_UNFAIR
>  	default n
>  	---help---
>  	Scalable TCP is a sender-side only change to TCP which uses a

