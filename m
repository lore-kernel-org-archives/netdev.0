From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 6/6] net: sh_eth: use NAPI
Date: Tue, 15 May 2012 01:07:53 -0400 (EDT)
Message-ID: <20120515.010753.2012331320750491448.davem@davemloft.net>
References: <4FB0AA7C.1000603@renesas.com>
	<20120514.185034.399229364191924851.davem@davemloft.net>
	<4FB1DFF0.4040709@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4FB1DFF0.4040709@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 15 May 2012 13:47:44 +0900

> 2012/05/15 7:50, David Miller wrote:
>> You need strict synchronization between your TX queueing and TX
>> liberation flows.  So that queue stop and wake are only performed
>> at the correct moment.
> 
> I will add netif_queue_stopped() in the sh_eth_poll().

That doesn't fix the bug.  What if someone transmits a packet and
fills the TX queue between the netif_queue_stopped() test and the
call to netif_wake_queue()?

Adding another test doesn't create the necessary synchronization.
