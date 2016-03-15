From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] ravb: fix result value overwrite
Date: Tue, 15 Mar 2016 20:10:09 +0300
Message-ID: <56E841F1.6050800@cogentembedded.com>
References: <1458057136-23253-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1458057136-23253-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/15/2016 06:52 PM, Yoshihiro Kaneko wrote:

> The result value is overwritten by a return value of
> ravb_ptp_interrupt().
>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 86449c3..d369af8 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -765,8 +765,8 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
>   		result = IRQ_HANDLED;
>   	}
>
> -	if (iss & ISS_CGIS)
> -		result = ravb_ptp_interrupt(ndev);

    I clearly meant to use |= here instead. Uh oh... :-(

> +	if ((iss & ISS_CGIS) && ravb_ptp_interrupt(ndev) == IRQ_HANDLED)
> +		result = IRQ_HANDLED;

MBR, Sergei
