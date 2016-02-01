From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net 3/6] net: mvneta: Remove unused code
Date: Mon, 1 Feb 2016 16:32:05 +0300
Message-ID: <56AF5E55.9030603@cogentembedded.com>
References: <1454332067-16378-1-git-send-email-gregory.clement@free-electrons.com>
 <1454332067-16378-4-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454332067-16378-4-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/1/2016 4:07 PM, Gregory CLEMENT wrote:

> Since the commit 2dcf75e2793c ("net: mvneta: Associate RX queues with
> each CPU") all the percpu irq are used and unmask at initialization, so

    Unmasked, you mean?

> there is no point to unmask them first.

    Mask, maybe (looking at the patch)?

> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> ---
>   drivers/net/ethernet/marvell/mvneta.c | 8 --------
>   1 file changed, 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 3d6e3137f305..861b7e0d7d5f 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3009,14 +3009,6 @@ static int mvneta_open(struct net_device *dev)
>   		goto err_cleanup_txqs;
>   	}
>
> -	/* Even though the documentation says that request_percpu_irq
> -	 * doesn't enable the interrupts automatically, it actually
> -	 * does so on the local CPU.
> -	 *
> -	 * Make sure it's disabled.
> -	 */
> -	mvneta_percpu_disable(pp);
> -
>   	/* Enable per-CPU interrupt on all the CPU to handle our RX
>   	 * queue interrupts
>   	 */

MBR, Sergei
