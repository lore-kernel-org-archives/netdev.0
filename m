From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: priv->lock can be used uninitialized
Date: Tue, 30 Nov 2010 15:12:08 +0100
Message-ID: <4CF50638.7000203@st.com>
References: <9345448e435110e2bdff65bb4322060a6f1f6b63.1291106902.git.vlad.lungu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Vlad Lungu <vlad.lungu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:50801 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752783Ab0K3OPT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 09:15:19 -0500
In-Reply-To: <9345448e435110e2bdff65bb4322060a6f1f6b63.1291106902.git.vlad.lungu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad.

On 11/30/2010 9:52 AM, Vlad Lungu wrote:
>
> To reproduce: if connman (http://connman.net/) is started,
> inserting the stmmac module triggers a "BUG: spinlock bad magic on CPU#0".
>
> Registering the device in stmmac_probe() sends a notification to connman
> which brings the interface up before the lock is initialized.
>

I've never tested connman on our ST platforms.
I've never seen this problems too.
I've no concerns on it so it could be applied.

Regards
Peppe

> Signed-off-by: Vlad Lungu <vlad.lungu@windriver.com>
> ---
>  drivers/net/stmmac/stmmac_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/stmmac/stmmac_main.c
> b/drivers/net/stmmac/stmmac_main.c
> index 730a6fd..e960501 100644
> --- a/drivers/net/stmmac/stmmac_main.c
> +++ b/drivers/net/stmmac/stmmac_main.c
> @@ -1516,6 +1516,8 @@ static int stmmac_probe(struct net_device *dev)
>                 pr_warning("\tno valid MAC address;"
>                         "please, use ifconfig or nwhwconfig!\n");
>
> +       spin_lock_init(&priv->lock);
> +
>         ret = register_netdev(dev);
>         if (ret) {
>                 pr_err("%s: ERROR %i registering the device\n",
> @@ -1527,8 +1529,6 @@ static int stmmac_probe(struct net_device *dev)
>             dev->name, (dev->features & NETIF_F_SG) ? "on" : "off",
>             (dev->features & NETIF_F_HW_CSUM) ? "on" : "off");
>
> -       spin_lock_init(&priv->lock);
> -
>         return ret;
>  }
>
> --
> 1.6.0.2
>
