From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] stmmac: fix check for phydev being open
Date: Mon, 7 Sep 2015 21:19:58 +0300
Message-ID: <55EDD54E.7030205@cogentembedded.com>
References: <1441649709-12325-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	arc-linux-dev@synopsys.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441649709-12325-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/07/2015 09:15 PM, Alexey Brodkin wrote:

> Current implementation via IS_ERR(phydev) may make no sense because
> of_phy_attach() returns NULL on failure instead of error value.

> Still for checking result of phy_connect() IS_ERR() is useful.

> So adding explicit check for NULL.

> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: arc-linux-dev@synopsys.com
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 864b476..ad2ce3e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -837,7 +837,7 @@ static int stmmac_init_phy(struct net_device *dev)
>   				     interface);
>   	}
>
> -	if (IS_ERR(phydev)) {
> +	if (!phydev || IS_ERR(phydev)) {

    There's IS_ERR_OR_NULL().

WBR, Sergei
