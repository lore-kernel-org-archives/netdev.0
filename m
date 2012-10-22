From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Tue, 23 Oct 2012 01:10:22 +0400
Message-ID: <5085B63E.5070504@parallels.com>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com> <1350938702.8609.1299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29503 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157Ab2JVVKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 17:10:37 -0400
In-Reply-To: <1350938702.8609.1299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 12:45 AM, Eric Dumazet wrote:
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
> 
> By the way, this is not really safe in case device is renamed

Good point, actually. Getting a device name may be not very safe in terms of --
once we have the name there's no 100% guarantee, that this name corresponds to the
actual device the socket is bound to (it could be renamed after we strcpy-ed its
name). This problem doesn't exist when we get device index, as it cannot be changed.

Thanks,
Pavel
