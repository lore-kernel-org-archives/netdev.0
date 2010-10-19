From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Tue, 19 Oct 2010 17:43:12 -0300
Message-ID: <20101019204312.GH8781@llucax.com.ar>
References: <4CBCD429.8090306@windriver.com>
 <20101018234547.GA5703@hmsreliant.think-freely.org>
 <20101019021657.GZ8781@llucax.com.ar>
 <20101019.011649.71113115.davem@davemloft.net>
 <20101019110452.GA14410@hmsreliant.think-freely.org>
 <20101019131936.GB8781@llucax.com.ar>
 <20101019201841.GC14410@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, paul.gortmaker@windriver.com,
	jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101019201841.GC14410@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman, el 19 de octubre a las 16:18 me escribiste:
> Hey all-
> 	Heres what I have so far.  Dave as a heads up please don't apply this
> yet.  I'd like to go over it a bit more and be sure of the implications here
> before I post it for inclusion officially.  I wanted Leandro to have a copy
> though so he could confirm functionality for us.  Leandro, This patch lets me
> pass the tipc test code for TIPC 1.6 that you posted earlier this morning.  If
> you could confirm that it works for you that would be grand.  While your doing
> that, I want to read over the spec for TIPC and make sure that I'm not breaking
> anything new with this patch.

Thanks for the quick response. I didn't tried the patch yet, but I think
spotted an error:

> diff --git a/include/linux/tipc.h b/include/linux/tipc.h
> index 181c8d0..d8de884 100644
> --- a/include/linux/tipc.h
> +++ b/include/linux/tipc.h
> @@ -127,9 +127,10 @@ static inline unsigned int tipc_node(__u32 addr)
>   * TIPC topology subscription service definitions
>   */
>  
> -#define TIPC_SUB_SERVICE     	0x00  	/* Filter for service availability    */
> -#define TIPC_SUB_PORTS     	0x01  	/* Filter for port availability  */
> +#define TIPC_SUB_SERVICE     	0x01  	/* Filter for service availability    */
> +#define TIPC_SUB_PORTS     	0x02  	/* Filter for port availability  */
>  #define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
> +#define TIPC_SUB_MASK		(TIPC_SUB_SERVICE|TIPC_SUB_PORTS|TIPC_SUB_CANCEL)
>  
>  #define TIPC_WAIT_FOREVER	~0	/* timeout for permanent subscription */
>  

The values of TIPC_SUB_SERVICE and TIPC_SUB_PORTS seem to be swapped
compared to the old (TIPC 1.6) values:
#define TIPC_SUB_PORTS     	0x01  	/* filter for port availability */
#define TIPC_SUB_SERVICE     	0x02  	/* filter for service availability */

You might missed this error when trying the code I posted earlier (which
BTW are the official TIPC demos) because the change of behaviour when
using TIPC_SUB_SERVICE and TIPC_SUB_PORTS is very subtle (the former
reports only the first published port name that matches, and the later
all the published ports that match).

I'll test the patch tomorrow morning (ART).

Thanks again.

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
Long you live and high you fly
And smiles you'll give and tears you'll cry
And all you touch and all you see
Is all your life will ever be.
