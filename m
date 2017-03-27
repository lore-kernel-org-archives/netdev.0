From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Mon, 27 Mar 2017 20:49:01 +0200
Message-ID: <20170327184901.GC8441@Red>
References: <20170325072621.GA20997@Red>
 <74765cbf-897a-67a1-7f42-337bf7dff6a8@synopsys.com>
 <20170327170058.GA8441@Red>
 <20170327.102831.1248194814523871799.davem@davemloft.net>
 <c8ec25cb-0369-a1b3-9f5b-dfd1ed6f9148@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36321 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdC0StQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:49:16 -0400
Received: by mail-wr0-f196.google.com with SMTP id u1so15953433wra.3
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:49:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c8ec25cb-0369-a1b3-9f5b-dfd1ed6f9148@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 06:44:22PM +0100, Joao Pinto wrote:
> Às 6:28 PM de 3/27/2017, David Miller escreveu:
> > From: Corentin Labbe <clabbe.montjoie@gmail.com>
> > Date: Mon, 27 Mar 2017 19:00:58 +0200
> > 
> >> On Mon, Mar 27, 2017 at 04:26:48PM +0100, Joao Pinto wrote:
> >>> Hi David,
> >>>
> >>> Às 7:26 AM de 3/25/2017, Corentin Labbe escreveu:
> >>>> On Fri, Mar 24, 2017 at 05:16:45PM +0000, Joao Pinto wrote:
> >>>>> For cores that have more than 1 TX queue configured, the kernel would crash,
> >>>>> since only one TX queue is permitted by default.
> >>>>>
> >>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> >>>>> ---
> >>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
> >>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>>>>
> >>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>> index 3827952..1eab084 100644
> >>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>> @@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
> >>>>>  	struct stmmac_rx_queue *rx_q =
> >>>>>  		container_of(napi, struct stmmac_rx_queue, napi);
> >>>>>  	struct stmmac_priv *priv = rx_q->priv_data;
> >>>>> -	u32 tx_count = priv->dma_cap.number_tx_queues;
> >>>>> +	u32 tx_count = priv->plat->tx_queues_to_use;
> >>>>>  	u32 chan = rx_q->queue_index;
> >>>>>  	u32 work_done = 0;
> >>>>>  	u32 queue = 0;
> >>>>> -- 
> >>>>> 2.9.3
> >>>>>
> >>>>
> >>>> This patch fix the performance issue on dwmac-sun8i only.
> >>>> The dwmac-sunxi is still broken.
> >>>>
> >>>
> >>> This patch series can be upstreamed please, since they make 2 fixes, one of them
> >>> solving the problem in dwmac-sun8i.
> >>>
> >>> Thanks.
> >>
> >> As I said in a previous answer, finaly dwmac-sun8i is still broken.
> >> Adding thoses 2 patch will just made the revert harder.
> > 
> > I agree.
> 
> For what I am understanding, SoCs base on Core versions >= 4.00 are working
> properly and for some reason SoCs based on older versions are not working.
> 
> This fix is necessary, since if you have a diferent configured tx_queues_to_use
> in the driver and priv->dma_cap.number_tx_queues in the core, this can lead to
> kernel crashes.
> 
> The other fix (netdev resources release) is also necessary, since when you
> release the driver its crashes, because the rx queue struct is freed before
> releasing the netdevs.
> 
> We can revert, but I think it might not solve the issue. We can break the
> "multiple buffers" patch into "rx multilple buffers" and "tx multiple buffers",
> but will that actually work? We can give it a try, I don't mind making a new
> multiple buffers patch broken into 2, that can be tested by new cores and older
> cores.
> 

Reverting at least will bring back my archs to good status:)
Spliting will not solve magically the issue, but will permit to easily detect which part is faulty.
And I am sure that it is possible to split more than in 2.
The more small the patch will be, the easier it will.

Regards
