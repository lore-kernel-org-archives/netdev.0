From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ethernet: nxp: use resource_size()
Date: Tue, 12 Mar 2013 12:10:31 -0700
Message-ID: <1363115431.2125.13.camel@joe-AO722>
References: <1363113035-11269-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, stigge@antcom.de,
	edumazet@google.com, gregkh@linuxfoundation.org, jiri@resnulli.us,
	linux-kernel@vger.kernel.org
To: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363113035-11269-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-03-12 at 20:30 +0200, Silviu-Mihai Popescu wrote:
> Use resource_size() instead of explicit calculation. This was found via
> make coccicheck.
[]
> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
[]
> @@ -1421,7 +1421,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
>  	netdev_dbg(ndev, "IO address start     :0x%08x\n",
>  			res->start);
>  	netdev_dbg(ndev, "IO address size      :%d\n",
> -			res->end - res->start + 1);
> +			resource_size(res));

This might be better as

	netdev_dbg(ndev, "IO resource    :%pR\n", res);
