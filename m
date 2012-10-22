From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 17:20:48 -0400
Message-ID: <5085B8B0.6010500@hp.com>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com> <1350938702.8609.1299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:44561 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756191Ab2JVVUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:20:51 -0400
In-Reply-To: <1350938702.8609.1299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2012 04:45 PM, Eric Dumazet wrote:
> On Mon, 2012-10-22 at 14:04 -0400, Brian Haley wrote:
> 
>> +	char devname[IFNAMSIZ];
>> +
>> +	ret = 0;
>> +	if (sk->sk_bound_dev_if == 0)
>> +		goto out;
>> +
>> +	ret = -EINVAL;
>> +	if (len < IFNAMSIZ)
>> +		goto out;
>> +	if (len > IFNAMSIZ)
>> +		len = IFNAMSIZ;
>> +
>> +	rcu_read_lock();
>> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
>> +	if (dev)
>> +		strcpy(dev->name, devname);
>> +	rcu_read_unlock();
>> +	ret = -ENODEV;
> 
> You probably meant
> 
> 	strcpy(devname, dev->name)

Yes, that was a stupid mistake, I'll fix it.

> By the way, this is not really safe in case device is renamed

It's not much different from what's there:

	setsockopt("foo");

	rename foo -> bar

	index = getsockopt();
	if_indextoname(index) -> "bar"

I more raised the issue since you pass a 'char *' to setsockopt() but an 'int *'
to getsockopt(), I don't think any other value is non-symmetrical like this.

-Brian
