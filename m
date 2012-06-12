From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH net-next 5/5] net: sh_eth: use NAPI
Date: Tue, 12 Jun 2012 15:47:00 +0900
Message-ID: <4FD6E5E4.7030702@renesas.com>
References: <4FD6D154.1000000@renesas.com>
 <1339480115.22704.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <1339480115.22704.20.camel@edumazet-glaptop>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/06/12 14:48, Eric Dumazet wrote:
> On Tue, 2012-06-12 at 14:19 +0900, Shimoda, Yoshihiro wrote:
< snip >
>> +	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
>> +		if (netif_msg_tx_queued(mdp)) {
>> +			dev_warn(&ndev->dev, "TxFD exhausted.\n");
>> +			netif_stop_queue(ndev);
>> +		}
>> +	}
>> +
>>  	return NETDEV_TX_OK;
>>  }
> 
> 
> I have no idea why you call netif_stop_queue() only if
> netif_msg_tx_queued(mdp)
> 
> You should test your driver under heavy TX load.
> 

Thank you for the point.
I checked the netif-msg.txt about netif_msg_tx_queued(). It is one of
the network interface message level setting. So, the driver's behavior
should not be changed by the level, I think.
I will modify the patch.

Best regards,
Yoshihiro Shimoda
