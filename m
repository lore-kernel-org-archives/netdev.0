From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Mon, 27 Mar 2017 11:09:41 +0200
Message-ID: <20170327090941.GC12523@Red>
References: <cover.1490375512.git.jpinto@synopsys.com>
 <b6f44c16abea1693dcc1333517778bd7a3e0b0f5.1490375512.git.jpinto@synopsys.com>
 <20170325072621.GA20997@Red>
 <9f9f20d0-198b-6928-6c78-6982030f9101@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36165 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbdC0JLF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:11:05 -0400
Received: by mail-wr0-f194.google.com with SMTP id u1so11090579wra.3
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 02:10:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <9f9f20d0-198b-6928-6c78-6982030f9101@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 10:04:57AM +0100, Joao Pinto wrote:
> Às 7:26 AM de 3/25/2017, Corentin Labbe escreveu:
> > On Fri, Mar 24, 2017 at 05:16:45PM +0000, Joao Pinto wrote:
> >> For cores that have more than 1 TX queue configured, the kernel would crash,
> >> since only one TX queue is permitted by default.
> >>
> >> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> >> ---
> >>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> index 3827952..1eab084 100644
> >> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> @@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
> >>  	struct stmmac_rx_queue *rx_q =
> >>  		container_of(napi, struct stmmac_rx_queue, napi);
> >>  	struct stmmac_priv *priv = rx_q->priv_data;
> >> -	u32 tx_count = priv->dma_cap.number_tx_queues;
> >> +	u32 tx_count = priv->plat->tx_queues_to_use;
> >>  	u32 chan = rx_q->queue_index;
> >>  	u32 work_done = 0;
> >>  	u32 queue = 0;
> >> -- 
> >> 2.9.3
> >>
> > 
> > This patch fix the performance issue on dwmac-sun8i only.
> 
> Ok, great!
> 

Sorry, in the we, I see that my gigabit dwmac-sun8i didnt work... (but didnt have time to find why).

> > The dwmac-sunxi is still broken.
> > 
> 
> What is the difference between the setups?

dwmac-sun8i use chain mode, dwmac-sunxi use ring mode
