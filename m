From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH 2/2] net: netrom: refactor code in nr_add_node
Date: Sun, 22 Oct 2017 19:41:36 -0500
Message-ID: <20171022194136.Horde.CG1baKiAVuDlzYkA6GaU9Xb@gator4166.hostgator.com>
References: <20171019172746.GA15332@embeddedor.com>
 <59E9BA66.4000707@bfs.de>
 <20171020110600.Horde.X15IwxxrG50sNBWbTzaM1pB@gator4166.hostgator.com>
 <59EA2A2D.4040003@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.108]:43436 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932158AbdJWAli (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 20:41:38 -0400
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id 51F59177E
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 19:41:37 -0500 (CDT)
In-Reply-To: <59EA2A2D.4040003@bfs.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quoting walter harms <wharms@bfs.de>:

> Am 20.10.2017 18:06, schrieb Gustavo A. R. Silva:
>> Hi Walter,
>>
>> Quoting walter harms <wharms@bfs.de>:
>>
>>> Am 19.10.2017 19:27, schrieb Gustavo A. R. Silva:
>>>> Code refactoring in order to make the code easier to read and maintain.
>>>>
>>>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>>>> ---
>>>> This code was tested by compilation only (GCC 7.2.0 was used).
>>>>
>>>>  net/netrom/nr_route.c | 63
>>>> ++++++++++++++++-----------------------------------
>>>>  1 file changed, 20 insertions(+), 43 deletions(-)
>>>>
>>>> diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
>>>> index fc9cadc..1e5165f 100644
>>>> --- a/net/netrom/nr_route.c
>>>> +++ b/net/netrom/nr_route.c
>>>> @@ -80,6 +80,23 @@ static struct nr_neigh
>>>> *nr_neigh_get_dev(ax25_address *callsign,
>>>>
>>>>  static void nr_remove_neigh(struct nr_neigh *);
>>>>
>>>> +/*      re-sort the routes in quality order.    */
>>>> +static inline void re_sort_routes(struct nr_node *nr_node, int ix_x,
>>>> int ix_y)
>>>> +{
>>>> +    struct nr_route nr_route;
>>>> +
>>>> +    if (nr_node->routes[ix_y].quality >
>>>> nr_node->routes[ix_x].quality) {
>>>> +        if (nr_node->which == ix_x)
>>>> +            nr_node->which = ix_y;
>>>> +        else if (nr_node->which == ix_y)
>>>> +            nr_node->which = ix_x;
>>>> +
>>>> +        nr_route              = nr_node->routes[ix_x];
>>>> +        nr_node->routes[ix_x] = nr_node->routes[ix_y];
>>>> +        nr_node->routes[ix_y] = nr_route;
>>>> +    }
>>>> +}
>>>> +
>>>
>>>
>>> Good idea, a bit of nit picking ..
>>> does ix_ has a special meaning ? otherwise x,y would be sufficient.
>>
>> ix typical stands for index, but I think just x and y are fine too.
>>
>>> From the code below i can see: y=x+1 Perhaps that can be used.
>>>
>>
>> So are you proposing to use two arguments instead of three?
>>
>> re_sort_routes(nr_node, 0);
>>
>
> I am not sure, i would wait a bit and see if what improves readability.
> as Kevin Dawson pointed out: this is a sort here.
> Maybe there a nice way to do something like that (i do not know):
>
> case 3:
>   re_sort_routes(nr_node, 1,2)
> case 2:
>   re_sort_routes(nr_node, 0,1)
> case 1:
>   break;
>
> The question is: Is the sorted list needed or simply the maximum ?
>
> NTL is a good thing to chop down the function in smaller digestible
> peaces.
>

I'll use the swap macro as you suggested and leave the rest of this  
patch as is for now.

Dawson:
Thanks for pointing out the thing about the inline keyword. I'll remove it.

Thanks
--
Gustavo A. R. Silva

> re,
>  wh
>
>>
>>> kernel.h has a swap() macro. so you can
>>> swap(nr_node->routes[x],nr_node->routes[y]);
>>>
>>
>> Nice, I will use that macro.
>>
>>> hope that helps,
>>
>> Definitely. I appreciate your comments.
>>
>
>
>
>
>> Thanks!
>> --
>> Gustavo A. R. Silva
>>
>>
>>
>>
>>
>>
>>
