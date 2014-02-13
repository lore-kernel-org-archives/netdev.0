From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: remove useless if check from
 register_netdevice()
Date: Thu, 13 Feb 2014 14:21:48 -0500 (EST)
Message-ID: <20140213.142148.477625151411590832.davem@davemloft.net>
References: <1392266829-2365-1-git-send-email-kda@linux-powerpc.org>
	<CAADnVQJwP+ThozpeKOEvzoJRkYQvZgWyM9U+ixyeKKH9nkNb6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbaBMTVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 14:21:49 -0500
In-Reply-To: <CAADnVQJwP+ThozpeKOEvzoJRkYQvZgWyM9U+ixyeKKH9nkNb6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Thu, 13 Feb 2014 08:23:08 -0800

> On Wed, Feb 12, 2014 at 8:47 PM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
>> remove useless if check from register_netdevice()
>>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> ---
>> v1 -> v2: Fixed identation
>> ---
>>  net/core/dev.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 4ad1b78..21a72ad 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
>>         if (dev->netdev_ops->ndo_init) {
>>                 ret = dev->netdev_ops->ndo_init(dev);
>>                 if (ret) {
>> -                       if (ret > 0)
>> -                               ret = -EIO;
>> +                       ret = -EIO;
>>                         goto out;
> 
> why is it a useless check?
> seems perfectly valid to me.
> most of the time ndo_init() returns negative error code like -ENOMEM
> which we want
> to propagate further down and want to override it to -EIO if it's > 0

Agreed, and if it is useless then unconditionally returining -EIO is
absolutely the wrong thing to do.  We should always use whatever negative
error code ndo_init() gave us.

I'm not applying this patch.
