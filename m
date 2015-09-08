From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] stmmac: fix check for phydev being open
Date: Tue, 8 Sep 2015 14:20:02 +0300
Message-ID: <55EEC462.2000906@cogentembedded.com>
References: <1441701786-10789-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1441701786-10789-1-git-send-email-abrodkin@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/8/2015 11:43 AM, Alexey Brodkin wrote:

> Current check of phydev with IS_ERR(phydev) may make not much sense
> because of_phy_connect() returns NULL on failure instead of error value.
>
> Still for checking result of phy_connect() IS_ERR() makes perfect sense.
>
> So let's use combined check IS_ERR_OR_NULL() that covers both cases.
>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
> ---
>
> Changes compared to v2:
>   * Updated commit message with mention of of_phy_connect() instead of
>     of_phy_attach().
>   * Return ENODEV in case of of_phy_connect() failure
>
> Changes compared to v1:
>   * Use IS_ERR_OR_NULL() instead of discrete checks for null and err
>
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 864b476..e2c9c86 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -837,9 +837,12 @@ static int stmmac_init_phy(struct net_device *dev)
>   				     interface);
>   	}
>
> -	if (IS_ERR(phydev)) {
> +	if (IS_ERR_OR_NULL(phydev)) {
>   		pr_err("%s: Could not attach to PHY\n", dev->name);
> -		return PTR_ERR(phydev);
> +		if (!phydev)
> +			return -ENODEV;
> +		else
> +			return PTR_ERR(phydev);

    Don't need *else* after *return* and scripts/checkpatch.pl should have 
complained about that.

MBR, Sergei
