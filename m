From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: Optimization for RX excess judgement
Date: Mon, 08 Dec 2014 14:47:25 +0300
Message-ID: <54858FCD.3080206@cogentembedded.com>
References: <1418035701-3871-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1418035701-3871-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/8/2014 1:48 PM, Yoshihiro Kaneko wrote:

> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

> Both of 'boguscnt' and 'quota' have nearly meaning as the condition of
> the reception loop.
> In order to cut down redundant processing, this patch changes excess
> judgement.

> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---

> This patch is based on net-next tree.

> v2 [Yoshihiro Kaneko]
> * re-spin for net-next.
> * remove unneeded check of "quota".

    This is not a complete list. :-/

>   drivers/net/ethernet/renesas/sh_eth.c | 10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index dbe8606..266c9b2 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -1501,6 +1499,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>   		sh_eth_write(ndev, EDRRR_R, EDRRR);
>   	}
>
> +	*quota -= limit - boguscnt + 1;
> +

    Sorry for the wrong previous suggestion, it clearly should have been -1, 
not +1. :-<

[...]

WBR, Sergei

