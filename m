From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hamradio: avoid null deref
Date: Wed, 23 Dec 2009 13:32:36 -0800 (PST)
Message-ID: <20091223.133236.104065227.davem@davemloft.net>
References: <20091223132550.GD17923@bicker>
	<4B3257C2.2050500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756792AbZLWVch@vger.kernel.org>
In-Reply-To: <4B3257C2.2050500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 23 Dec 2009 18:47:46 +0100

> Dan Carpenter wrote, On 12/23/2009 02:25 PM:
> 
>> If dev == NULL we shouldn't dereference it.
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
>> 
>> --- orig/drivers/net/hamradio/bpqether.c	2009-12-22 23:58:56.000000000 +0200
>> +++ devel/drivers/net/hamradio/bpqether.c	2009-12-22 23:59:46.000000000 +0200
>> @@ -283,7 +283,6 @@ static netdev_tx_t bpq_xmit(struct sk_bu
>>  	bpq = netdev_priv(dev);
>>  
>>  	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
>> -		dev->stats.tx_dropped++;
> 
> Why not use a separate variable for another dev? This stat
> should be helpful for debugging.

And that is definitely the intent of the code here, to
bump the statistic in the original device object.
