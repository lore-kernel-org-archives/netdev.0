From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] stmmac: fix check for phydev being open
Date: Mon, 7 Sep 2015 23:53:04 +0300
Message-ID: <55EDF930.10601@cogentembedded.com>
References: <1441659019-25522-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1441659019-25522-1-git-send-email-abrodkin@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2015 11:50 PM, Alexey Brodkin wrote:

> Current implementation via IS_ERR(phydev) may make no sense because
> of_phy_attach() returns NULL on failure instead of error value.
>
> Still for checking result of phy_connect() IS_ERR() is useful.
>
> To address both situations we use combined IS_ERR_OR_NULL() check.
>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> Cc: David Miller <davem@davemloft.net>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
> ---
>
> Changes compared to v1:
>   * Use IS_ERR_OR_NULL() instead of discrete checks for null and err
>
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 864b476..7985d8a 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -837,7 +837,7 @@ static int stmmac_init_phy(struct net_device *dev)
>   				     interface);
>   	}
>
> -	if (IS_ERR(phydev)) {
> +	if (IS_ERR_OR_NULL(phydev)) {
>   		pr_err("%s: Could not attach to PHY\n", dev->name);
>   		return PTR_ERR(phydev);

    Hm, in case of phydev == NULL, you're going to return 0 here... is that 
what you want?

MBR, Sergei
