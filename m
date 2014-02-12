From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next] net: remove useless if check from register_netdevice()
Date: Wed, 12 Feb 2014 12:47:22 +0400
Message-ID: <CAOJe8K32nXmX9X+OceP9e5gb-KwJKfAts=zeaDGUU-+R1Q8oaw@mail.gmail.com>
References: <1392191152-24182-1-git-send-email-kda@linux-powerpc.org>
	<52FB2FBF.7050907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:60585 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaBLIrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 03:47:23 -0500
Received: by mail-oa0-f54.google.com with SMTP id i4so10629746oah.13
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 00:47:22 -0800 (PST)
In-Reply-To: <52FB2FBF.7050907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/12/14, Ding Tianhong <dingtianhong@huawei.com> wrote:
> On 2014/2/12 15:45, Denis Kirjanov wrote:
>> remove useless if check from register_netdevice()
>>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> ---
>>  net/core/dev.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 4ad1b78..4be9a37 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
>>  	if (dev->netdev_ops->ndo_init) {
>>  		ret = dev->netdev_ops->ndo_init(dev);
>>  		if (ret) {
>> -			if (ret > 0)
>> -				ret = -EIO;
>> +            ret = -EIO;
>
> and:
> some ndo_init() will return -ENOMEM, not only -EIO
>
>
>>  			goto out;
>>  		}
>>  	}
>>

Yes, I was thinking about that. The return code may contain everything.
Probably it's better to propagate return value back to
register_netdevice. On the other hand the return value -ENOTSUPP for
register_netdevice return value looks odd...

>
