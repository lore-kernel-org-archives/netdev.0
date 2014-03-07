From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH RFC] net: davinci_emac: Fix rollback of emac_dev_open()
Date: Fri, 7 Mar 2014 20:15:00 +0530
Message-ID: <5319DB6C.8080203@ti.com>
References: <35CC5396F7326DBE44C9C624@[172.22.2.41]>
	<130fa9cb-7e94-4698-ac3f-f987a03c0604@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        Florian Fainelli
	<f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jon Ringle <jon-7zJyie9iPacdnm+yROfE0A@public.gmane.org>
To: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <130fa9cb-7e94-4698-ac3f-f987a03c0604-2Q1zT/7oKKveau+zUrS5eLNldLUNz+W/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 07 March 2014 07:37 PM, Christian Riesch wrote:
> Signed-off-by: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
> Cc: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>
> Hi again,
>
> How about this solution for fixing the rollback of emac_dev_open()?
> Especially the change in davinci_cpdma.c, would this break anything?
>
> The patch applies on top of 
> [PATCH] net: davinci_emac: Replace devm_request_irq with request_irq
>
> Regards,
> Christian
>
>  drivers/net/ethernet/ti/davinci_cpdma.c |    4 +--
>  drivers/net/ethernet/ti/davinci_emac.c  |   44 ++++++++++++++++++++-----------
>  2 files changed, 31 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
> index 364d0c7..88ef270 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -355,7 +355,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
>  	int i;
>  
>  	spin_lock_irqsave(&ctlr->lock, flags);
> -	if (ctlr->state != CPDMA_STATE_ACTIVE) {
> +	if (ctlr->state == CPDMA_STATE_TEARDOWN) {
>  		spin_unlock_irqrestore(&ctlr->lock, flags);
>  		return -EINVAL;
>  	}
> @@ -891,7 +891,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
>  	unsigned		timeout;
>  
>  	spin_lock_irqsave(&chan->lock, flags);
> -	if (chan->state != CPDMA_STATE_ACTIVE) {
> +	if (chan->state == CPDMA_STATE_TEARDOWN) {
>  		spin_unlock_irqrestore(&chan->lock, flags);
>  		return -EINVAL;
>  	}

Even when in idle mode chan stop should return error.

Regards
Mugunthan V N
