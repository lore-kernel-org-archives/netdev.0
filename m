From: bhartin@straus-frank.com
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Wed, 7 Apr 2004 00:15:27 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404070014571.17117@edp12.straus-frank.int>
References: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int>
 <20040126235559.A3832@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404041553010.6853@edp12.straus-frank.int>
 <20040405002028.A8125@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404061650310.20664@edp12.straus-frank.int>
 <20040407001815.C7833@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404061758570.17117@edp12.straus-frank.int>
 <20040407013841.A7978@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040407013841.A7978@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The patch resolved the PHY messages, and I stress-tested the networking 
again--it's still stable.

Thanks!

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company

On Wed, 7 Apr 2004, Francois Romieu wrote:

> bhartin@straus-frank.com <bhartin@straus-frank.com> :
> [...]
> > I got my laptop back up and found the messages logged:
> > 
> > kernel: r8169: eth0: Reset RTL8169s PHY
> > 
> > I didn't see exactly at what point this started happening during the 
> > shutdown, but the message repeated about 500 times before the system 
> > logger was stopped.
> 
> It implies a minimum of 6000 invocations of rtl8169_phy_timer(). 
> 
> *doh*
> 
> Please apply patch below.
> 
> 
> 
> mod_timer() expects an absolute time, not a relative offset.
> 
> 
>  drivers/net/r8169.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/r8169.c~r8169-mod_timer drivers/net/r8169.c
> --- linux-2.6.5/drivers/net/r8169.c~r8169-mod_timer	2004-04-07 01:30:14.000000000 +0200
> +++ linux-2.6.5-fr/drivers/net/r8169.c	2004-04-07 01:32:53.000000000 +0200
> @@ -617,7 +617,7 @@ static void rtl8169_phy_timer(unsigned l
>  		}
>  	}
>  
> -	mod_timer(timer, RTL8169_PHY_TIMEOUT);
> +	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
>  }
>  
>  static inline void rtl8169_delete_timer(struct net_device *dev)
> 
> _
> 

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company
