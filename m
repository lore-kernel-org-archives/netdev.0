From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 15:38:50 -0400 (EDT)
Message-ID: <20170614.153850.858684905893972084.davem@davemloft.net>
References: <1497452424.3765.3.camel@163.com>
        <1497457773.9377.2.camel@sipsolutions.net>
        <1497457908.9377.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: cugyly@163.com, netdev@vger.kernel.org,
        Linyu.Yuan@alcatel-sbell.com.cn
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54678 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751665AbdFNTix (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:38:53 -0400
In-Reply-To: <1497457908.9377.4.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 14 Jun 2017 18:31:48 +0200

> On Wed, 2017-06-14 at 18:29 +0200, Johannes Berg wrote:
>> On Wed, 2017-06-14 at 23:00 +0800, yuan linyu wrote:
>> 
>> > sorry, I do them by hand. 
>> 
>> oh, ok.
>> 
>> This seems to work:
>> 
>> @@
>> identifier p;
>> expression len;
>> expression skb;
>> type t;
>> @@
>> -p = (t)skb_put(skb, len);
>> -memset(p, 0, len);
>> +p = (t)skb_put_zero(skb, len);
> 
> Nope, still didn't find everything - not the batman and atm cases for
> example. But still a few more, I think that you didn't find, e.g. in
> mac80211.
> 
> Anyway - I think none of this is really critical.

What do you think about Stephen Hemminger's feedback to make skb_put_zero()
return "void *".  It will avoid a lot of casts and make the conversions
look nicer.

I'll also defer on this patch series until we have the spatch thing
which can catch all of them.

Thanks.
