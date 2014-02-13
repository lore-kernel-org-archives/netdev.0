From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH v2 net-next] net: remove useless if check from register_netdevice()
Date: Thu, 13 Feb 2014 21:15:46 +0400
Message-ID: <CAOJe8K2iTsv-HUEotjwpc7s9LMEU6+nMfK5VWWF0tcMLhYBS6Q@mail.gmail.com>
References: <1392266829-2365-1-git-send-email-kda@linux-powerpc.org>
	<CAADnVQJwP+ThozpeKOEvzoJRkYQvZgWyM9U+ixyeKKH9nkNb6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:63621 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbaBMRPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 12:15:48 -0500
Received: by mail-oa0-f46.google.com with SMTP id n16so13003287oag.19
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 09:15:46 -0800 (PST)
In-Reply-To: <CAADnVQJwP+ThozpeKOEvzoJRkYQvZgWyM9U+ixyeKKH9nkNb6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of the users of ndo_init return negative error code on error path.
Only staging stuff tries to use positive codes like octeon ethernet
which does request_irq inside ndo_open...

On 2/13/14, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> On Wed, Feb 12, 2014 at 8:47 PM, Denis Kirjanov <kda@linux-powerpc.org>
> wrote:
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
>
