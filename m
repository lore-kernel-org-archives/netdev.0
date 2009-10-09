From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] irda/sa1100_ir: check return value of startup hook
Date: Fri, 09 Oct 2009 16:14:52 +0400
Message-ID: <4ACF293C.7070803@ru.mvista.com>
References: <1255073153-24962-1-git-send-email-mad_soft@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Dmitry Artamonow <mad_soft@inbox.ru>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1255073153-24962-1-git-send-email-mad_soft@inbox.ru>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello.

Dmitry Artamonow wrote:

> Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>
[...]
> diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
> index 38bf7cf..df5db2d 100644
> --- a/drivers/net/irda/sa1100_ir.c
> +++ b/drivers/net/irda/sa1100_ir.c
> @@ -232,8 +232,11 @@ static int sa1100_irda_startup(struct sa1100_irda *si)
>  	/*
>  	 * Ensure that the ports for this device are setup correctly.
>  	 */
> -	if (si->pdata->startup)
> -		si->pdata->startup(si->dev);
> +	if (si->pdata->startup)	{
> +		ret = si->pdata->startup(si->dev);
> +		if (ret)
> +			return ret;
> +		}

    Overindented brace.

>  
>  	/*
>  	 * Configure PPC for IRDA - we want to drive TXD2 low.

WBR, Sergei
