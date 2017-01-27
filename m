From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next 1/2] ravb: Add tx and rx clock internal delays
 mode of APSR
Date: Fri, 27 Jan 2017 22:05:58 +0300
Message-ID: <0570b250-83eb-fbac-de2a-0ea99a7250c2@cogentembedded.com>
References: <1485542120-10205-1-git-send-email-horms+renesas@verge.net.au>
 <1485542120-10205-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1485542120-10205-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/27/2017 09:35 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch enables tx and rx clock internal delay modes (TDM and RDM).
>
> This is to address a failure in the case of 1Gbps communication using the
> by salvator-x board with the KSZ9031RNX phy. This has been reported to
> occur with both the r8a7795 (H3) and r8a7796 (M3-W) SoCs.
>
> With this change APSR internal delay modes are enabled for
> "rgmii-id", "rgmii-rxid" and "rgmii-txid" phy modes as follows:
>
> phy mode   | ASPR delay mode
> -----------+----------------
> rgmii-id   | TDM and RDM
> rgmii-rxid | RDM
> rgmii-txid | TDM
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---
> v2 [Simon Horman]
> * As suggested by Sergei Shtylyov
>   - Add a comment to indicate that APSR_DM appears to be undocumented.
>   - Move chip_id check outside of ravb_set_delay_mode for consistency
>   - Call ravb_modify() once in ravb_set_delay_mode()
> * Enhance comment before calls to ravb_set_delay_mode()

    Well, I meant to say that the comment should precede the body of the 
function, not be repeated at every call...

> * Remove unnecessary break from end of switch statement.

   Come on, you did remove all the *switch*. :-)

>
> v1 [Simon Horman]
> - Combined patches
> - Reworded changelog
>
> v0 [Kazuya Mizuguchi]
> ---
>  drivers/net/ethernet/renesas/ravb.h      | 10 ++++++++++
>  drivers/net/ethernet/renesas/ravb_main.c | 24 ++++++++++++++++++++++++
>  2 files changed, 34 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> index f1109661a533..0525bd696d5d 100644
> --- a/drivers/net/ethernet/renesas/ravb.h
> +++ b/drivers/net/ethernet/renesas/ravb.h
[...]
> @@ -248,6 +249,15 @@ enum ESR_BIT {
>  	ESR_EIL		= 0x00001000,
>  };
>
> +/* APSR */
> +enum APSR_BIT {
> +	APSR_MEMS		= 0x00000002,
> +	APSR_CMSW		= 0x00000010,
> +	APSR_DM			= 0x00006000,	/* Undocumented? */
> +	APSR_DM_RDM		= 0x00002000,
> +	APSR_DM_TDM		= 0x00004000,

    The field values are also undocumented if the field is...

[...]

MBR, Sergei
