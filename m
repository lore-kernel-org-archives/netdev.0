From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH 1/2 net] 6lowpan: add missing pskb_may_pull() check
Date: Thu, 10 May 2012 18:05:46 +0400
Message-ID: <CAJmB2rCo0CfHP992Jix=mtshSS-wn92rf+3yg-ZK1_KLkXKRGw@mail.gmail.com>
References: <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
	<1336656659.12504.153.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:43521 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759129Ab2EJOFs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 10:05:48 -0400
Received: by lahd3 with SMTP id d3so1099669lah.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 07:05:46 -0700 (PDT)
In-Reply-To: <1336656659.12504.153.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

2012/5/10 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2012-05-10 at 17:22 +0400, alex.bluesman.smirnov@gmail.com
> wrote:
>> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
>>
>> Add pskb_may_pull() call when fetching u8 from skb.
>>
>> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
>> ---
>> =A0net/ieee802154/6lowpan.c | =A0 =A02 ++
>> =A01 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>> index 32eb417..0ab3efe 100644
>> --- a/net/ieee802154/6lowpan.c
>> +++ b/net/ieee802154/6lowpan.c
>> @@ -295,6 +295,8 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff *sk=
b)
>> =A0{
>> =A0 =A0 =A0 u8 ret;
>>
>> + =A0 =A0 BUG_ON(!pskb_may_pull(skb, 1));
>> +
>> =A0 =A0 =A0 ret =3D skb->data[0];
>> =A0 =A0 =A0 skb_pull(skb, 1);
>>
>
> No, you cant do that.
>
> pskb_may_pull() can fail, and you crash your machine instead of grace=
ful
> error reporting.
>

thanks for the comment!

Using BUG() macro I just want to indicate that something in the bottom
of the stack went terribly wrong and you must check your code for
bugs..

>
>
