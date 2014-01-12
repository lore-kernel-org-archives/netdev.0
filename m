From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1] When timestamping is enabled, stmmac_tx_clean will
 call stmmac_get_tx_hwtstamp to get tx TS. It's possible that skb is NULL
 because there are other network frames that use several descriptors. So we
 must return immediately in stmmac_get_tx_hwtstamp if skb is NULL to avoid
 system crash.
Date: Sun, 12 Jan 2014 12:38:28 +0100
Message-ID: <52D27EB4.9050909@redhat.com>
References: <1389492095-6589-1-git-send-email-damuzi000@gmail.com> <20140112093951.GA3743@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bruce Liu <damuzi000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140112093951.GA3743@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2014 10:39 AM, Bruce Liu wrote:
>   When timestamping is enabled, stmmac_tx_clean will call stmmac_get_tx_hwtstamp to get tx TS.
>   It's possible that skb is NULL because there are other network frames that use several descriptors.
>   So we must return immediately in stmmac_get_tx_hwtstamp if skb is NULL to avoid system crash.
>
>
> Signed-off-by: Bruce Liu <damuzi000@gmail.com>

Please see Documentation/SubmittingPatches +489

You subject line is way too long and should just be something like:

[PATCH net-next] net: stmmac: fix NULL pointer dereference in stmmac_get_tx_hwtstamp

Don't indent your actual commit message with whitespaces as prefix,
and do a line break after around 70 chars.

Btw, I mentioned net-next in the subject since merge window will
open soon anyway.

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 797b56a..47f2287 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -332,7 +332,7 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
>   		return;
>
>   	/* exit if skb doesn't support hw tstamp */
> -	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
> +	if (likely(!skb || !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
>   		return;
>
>   	if (priv->adv_ts)
>
