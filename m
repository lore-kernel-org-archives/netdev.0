From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 10/16] drivers/net/ethernet/ibm/emac/mal.c: use WARN
Date: Sat, 03 Nov 2012 17:26:40 +0100
Message-ID: <509545C0.5050000@bfs.de>
References: <1351940317-14812-1-git-send-email-Julia.Lawall@lip6.fr> <1351940317-14812-11-git-send-email-Julia.Lawall@lip6.fr> <50950055.8040307@bfs.de> <alpine.DEB.2.02.1211031513220.1955@localhost6.localdomain6>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1211031513220.1955@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 03.11.2012 15:14, schrieb Julia Lawall:
> On Sat, 3 Nov 2012, walter harms wrote:
> 
>>
>>
>> Am 03.11.2012 11:58, schrieb Julia Lawall:
>>> From: Julia Lawall <Julia.Lawall@lip6.fr>
>>>
>>> Use WARN rather than printk followed by WARN_ON(1), for conciseness.
>>>
>>> A simplified version of the semantic patch that makes this
>>> transformation
>>> is as follows: (http://coccinelle.lip6.fr/)
>>>
>>> // <smpl>
>>> @@
>>> expression list es;
>>> @@
>>>
>>> -printk(
>>> +WARN(1,
>>>   es);
>>> -WARN_ON(1);
>>> // </smpl>
>>>
>>> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>>>
>>> ---
>>>  drivers/net/ethernet/ibm/emac/mal.c |    6 ++----
>>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/ibm/emac/mal.c
>>> b/drivers/net/ethernet/ibm/emac/mal.c
>>> index 479e43e..84c6b6c 100644
>>> --- a/drivers/net/ethernet/ibm/emac/mal.c
>>> +++ b/drivers/net/ethernet/ibm/emac/mal.c
>>> @@ -738,13 +738,11 @@ static int __devexit mal_remove(struct
>>> platform_device *ofdev)
>>>      /* Synchronize with scheduled polling */
>>>      napi_disable(&mal->napi);
>>>
>>> -    if (!list_empty(&mal->list)) {
>>> +    if (!list_empty(&mal->list))
>>>          /* This is *very* bad */
>>> -        printk(KERN_EMERG
>>> +        WARN(1, KERN_EMERG
>>>                 "mal%d: commac list is not empty on remove!\n",
>>>                 mal->index);
>>> -        WARN_ON(1);
>>> -    }
>>>
>>>      dev_set_drvdata(&ofdev->dev, NULL);
>>>
>>>
>>
>> Hi Julia,
>> you are removing the {} behin the if. I prefer to be a bit conservative
>> about {}. There is suggest to keep them because WARN may be expanded in
>> future (with a second line) and that will cause subtle changes that do
>> no break the code. (Yes i know it is possible to write macros that
>> contain savely more than one line.)
> 
> WARN is already multi-line, surrounded by ({ }).  It seems to be set up
> to be used as an expression.  Is it necessary to assume that it might
> someday be changed from safe to unsafe?
> 

my bad,
NTL looks like a candidate for a function.

While looking i have noticed that a lot of drivers define there private "assert" macro.
It is very similar to warn.

(e.g.)
 #define RTL819x_DEBUG
 #ifdef RTL819x_DEBUG
 #define assert(expr) \
        if (!(expr)) {                                  \
                 printk( "Assertion failed! %s,%s,%s,line=%d\n", \
                #expr,__FILE__,__FUNCTION__,__LINE__);          \
        }

re,
 wh
