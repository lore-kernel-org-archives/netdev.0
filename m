From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] ixp4xx_eth: set the device dma_coherent_mask
Date: Tue, 19 Mar 2013 22:34:25 +0530
Message-ID: <51489A99.2030107@ti.com>
References: <1363708765-20778-1-git-send-email-c.aeschlimann@acn-group.ch> <20130319.123359.2245221095583640859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <aeschlimann@gmail.com>, <khc@pm.waw.pl>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <c.aeschlimann@acn-group.ch>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130319.123359.2245221095583640859.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/19/2013 10:03 PM, David Miller wrote:
> From: Christophe Aeschlimann<aeschlimann@gmail.com>
> Date: Tue, 19 Mar 2013 16:59:25 +0100
>
>> >Without the mask it is impossible to take the network interface up
>> >since it returns the following error:
>> >
>>> >>net eth1: coherent DMA mask is unset
>>> >>ifconfig: SIOCSIFFLAGS: Cannot allocate memory
>> >
>> >Tested on an out-of-tree ixp425 based board.
>> >
>> >Signed-off-by: Christophe Aeschlimann<c.aeschlimann@acn-group.ch>
>   ...
>> >@@ -1398,6 +1398,7 @@ static int eth_init_one(struct platform_device *pdev)
>> >  		return -ENOMEM;
>> >  
>> >  	SET_NETDEV_DEV(dev, &pdev->dev);
>> >+	dev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
> Hmmm, shouldn't this be the default value, set by the bus layer or
> similar?
bus layer or any platform code doesn't init this value. The same issue 
applies
to CPSW driver also. Previously the same was done in board or device 
file. But
this approach is obsolete now, need to think of how it can be resolved in DT
approach

Regards
Mugunthan V N
