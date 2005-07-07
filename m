From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Thu, 7 Jul 2005 16:15:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507071552130.24321@resonance.WorkGroup>
References: <20050707222741.71C3E89826@linux.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev@vger.kernel.org,
        ravinandan.arakali@neterion.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raghavendra.koushik@neterion.com
In-Reply-To: <20050707222741.71C3E89826@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Thu, 7 Jul 2005 raghavendra.koushik@neterion.com wrote:

> .......
> 2. Removed unnecessary PIOs(read/write of tx_traffic_int and 
>    rx_traffic_int) from interrupt handler and removed read of
>    general_int_status register from xmit routine.			    
> ......
> @@ -2891,6 +2869,8 @@ int s2io_xmit(struct sk_buff *skb, struc
>  	val64 = mac_control->fifos[queue].list_info[put_off].list_phy_addr;
>  	writeq(val64, &tx_fifo->TxDL_Pointer);
>  
> +	wmb();
> +
>  	val64 = (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
>  		 TX_FIFO_LAST_LIST);
>  
> @@ -2900,9 +2880,6 @@ int s2io_xmit(struct sk_buff *skb, struc
>  #endif
>  	writeq(val64, &tx_fifo->List_Control);
>  
> -	/* Perform a PCI read to flush previous writes */
> -	val64 = readq(&bar0->general_int_status);
> -
>  	put_off++;
                                                                  
I thought that an mmiowb() was called for here (to order the PIO 
writes above more cheaply than doing the readq()). I posted a 
patch like this some time ago:

http://marc.theaimsgroup.com/?l=linux-netdev&m=111508292028110&w=2

FWIW, I've done quite a few performance measurements with the patch 
I posted earlier, and it's worked well. For 1500 byte mtus throughput 
goes up by ~20%. Is even the mmiowb() unnecessary?

What is the wmb() above for?

--
Arthur
