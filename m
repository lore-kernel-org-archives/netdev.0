From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: Use common error handling code in ravb_probe()
Date: Mon, 30 Oct 2017 23:51:09 +0300
Message-ID: <b45f9416-5b89-17e3-df0b-905dd01d5342@cogentembedded.com>
References: <2839c3c2-0116-7549-6ff4-a49eb0a52298@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eugeniu Rosca <erosca@de.adit-jv.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2839c3c2-0116-7549-6ff4-a49eb0a52298@users.sourceforge.net>
Content-Language: en-MW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 10/28/2017 08:19 PM, SF Markus Elfring wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 28 Oct 2017 19:10:08 +0200
> 
> Add a jump target so that a bit of exception handling can be better reused
> at the end of this function.

    Have you actually tried to see if there's any change in the resulting 
object code? I've looked at ARM gcc 4.8.5's output and it didn't really change 
-- gcc was able to optimize these repetitive assignments pretty well...

> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>   drivers/net/ethernet/renesas/ravb_main.c | 32 ++++++++++++++++----------------
>   1 file changed, 16 insertions(+), 16 deletions(-)

    Diffstat also speaks about the futility of this patch.

> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index a8822a756e08..62dbdf7de6cd 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c

> @@ -2226,6 +2222,10 @@ static int ravb_probe(struct platform_device *pdev)
>   	pm_runtime_put(&pdev->dev);
>   	pm_runtime_disable(&pdev->dev);
>   	return error;
> +
> +failure_indication:

    Pretty poor label name -- I would've preferred 'no_irq' or smth...

> +	error = irq;
> +	goto out_release;

    The only good thing is that looking at the assembly, I was able to figure 
out that 'ndev' check at 'out_release' is futile... :-)

[...]

MBR, Sergei
