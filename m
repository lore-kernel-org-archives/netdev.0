From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH net] drivers: net: xgene: fix possible use after free
Date: Fri, 27 Nov 2015 19:34:24 -0800
Message-ID: <CAKh23FkcjtJVrP91x5dBkKZ=nK6anp5dmFmsUm1-58McSQSWbg@mail.gmail.com>
References: <20151125155753.GE12434@leverpostej>
 <1448468256.24696.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151125163402.GA29094@leverpostej>
 <1448470930.24696.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, netdev <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 ryabinin.a.a@gmail.com, Keyur Chudgar <kchudgar@apm.com>,
 David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1448470930.24696.10.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 9:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Once TX has been enabled on a NIC, it is illegal to access skb,
> as this skb might have been freed by another cpu, from TX completion
> handler.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Mark Rutland <mark.rutland@arm.com>
> Tested-by: Mark Rutland <mark.rutland@arm.com>
> Cc: Iyappan Subramanian <isubramanian@apm.com>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 1adfe7036843..9147a0107c44 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -450,12 +450,12 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
>                 return NETDEV_TX_OK;
>         }
>
> -       pdata->ring_ops->wr_cmd(tx_ring, count);
>         skb_tx_timestamp(skb);
>
>         pdata->stats.tx_packets++;
>         pdata->stats.tx_bytes += skb->len;
>
> +       pdata->ring_ops->wr_cmd(tx_ring, count);

Thanks Mark and Eric, for the fix.

Acked-by: Iyappan Subramanian <isubramanian@apm.com>

>         return NETDEV_TX_OK;
>  }
>
>
>
