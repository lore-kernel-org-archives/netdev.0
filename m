From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH 4/5] r8169: ethtool message level control
Date: Sat, 12 Mar 2005 12:02:23 +0000
Message-ID: <4232DA4F.5050804@phekda.gotadsl.co.uk>
References: <20050309113402.05d25e49@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309113402.05d25e49@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Stephen Hemminger wrote:
> Add ethtool message level control support. This is the standard way
> to enable/disable console log messages.  Also, ratelimit the too much
> work at interrupt message, so if under massive packet load the console
> doesn't get flooded.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
> --- a/drivers/net/r8169.c	2005-03-09 11:25:04 -08:00
> +++ b/drivers/net/r8169.c	2005-03-09 11:25:04 -08:00
[snip]
> @@ -875,12 +885,26 @@
>          spin_unlock_irqrestore(&tp->lock, flags);
>  }
>  
> +static u32 rtl8169_get_msglevel(struct net_device *dev)
> +{
> +        struct rtl8169_private *tp = netdev_priv(dev);
> +	return tp->msg_enable;
> +}
> +
> +static void rtl8169_set_msglevel(struct net_device *dev, u32 value)
> +{
> +        struct rtl8169_private *tp = netdev_priv(dev);
> +	tp->msg_enable = value;
> +}
> +
[snip]

When I posted a patch for message level support a couple of weeks ago 
(and got a ton of corrective feedback), Francois asked that there be 
whitespace separating the definitions from executable code in these 
functions.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
