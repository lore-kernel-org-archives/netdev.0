From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] cleanup large frame handling for natsemi.c
Date: Sun, 20 Jun 2004 21:31:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D5E60A.10007@colorfullife.com>
References: <40D57FC3.9040008@colorfullife.com> <20040620163036.GD16038@havoc.gtf.org> <40D5BE9B.9040106@colorfullife.com> <20040620183855.GA26392@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040620183855.GA26392@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

>On Sun, Jun 20, 2004 at 06:43:07PM +0200, Manfred Spraul wrote:
>  
>
>>@@ -1909,9 +1916,13 @@
>> 	np->dirty_rx = 0;
>> 	np->cur_rx = RX_RING_SIZE;
>> 	np->oom = 0;
>>-	np->rx_buf_sz = PKT_BUF_SZ;
>>-	if (dev->mtu > ETH_DATA_LEN)
>>-		np->rx_buf_sz += dev->mtu - ETH_DATA_LEN;
>>+	if (dev->mtu <= ETH_DATA_LEN)
>>+		np->rx_buf_sz = ETH_DATA_LEN + NATSEMI_HEADERS;
>>+	else
>>+		np->rx_buf_sz = dev->mtu + NATSEMI_HEADERS;
>>+	if (np->rx_buf_sz > NATSEMI_RX_LIMIT)
>>+		np->rx_buf_sz = NATSEMI_RX_LIMIT;
>>+
>>    
>>
>
>Double NAK:
>
>1) Use PKT_BUF_SZ, don't alloc smaller than that.
>
>  
>
The alloc size is never smaller than PKT_BUF_SZ: 
ETH_DATA_LEN+NATSEMI_HEADERS+NATSEMI_PADDING is 1586 bytes [still 
smaller than the 1620 byte skb kmalloc cache]

>2) The final check should not be needed.  The code should guarantee that
>np->rx_buf_sz never exceeds NATSEMI_RX_LIMIT.
>
>  
>
You mean: implement a change_mtu callback and reject mtu values above 
2020 byte?

--
    Manfred

>	Jeff
>
>
>  
>
