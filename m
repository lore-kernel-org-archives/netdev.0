From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 2/5] net: ethernet: ti: davinci_cpdma: fix locking
 while ctrl_stop
Date: Wed, 17 Aug 2016 11:12:25 +0530
Message-ID: <1ea7e2ef-2677-91e9-63f5-c12b58fa3287@ti.com>
References: <1471303549-4134-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1471303549-4134-3-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<nsekhar@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471303549-4134-3-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 August 2016 04:55 AM, Ivan Khoronzhuk wrote:
> The interrupts shouldn't be disabled while receiving skb, but while
> ctrl_stop, the channels are stopped and all remaining packets are
> handled with netif_receive_skb():
> 
> lock_irq_save
>     cpdma_ctlr_stop
>        cpdma_chan_top
>            __cpdma_chan_free
>                cpsw_rx_handler
>                    netif_receive_skb
> 
> So, split locking while ctrl stop thus interrupts are still
> enabled while skbs handling. It can cause WARN_ONCE in rare
> cases when ctrl is stopping while not all packets were handled
> with NAPIs.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
