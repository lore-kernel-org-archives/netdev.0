From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fib: fib6_add: fix potential NULL pointer
 dereference
Date: Wed, 11 Sep 2013 16:14:29 -0400 (EDT)
Message-ID: <20130911.161429.1045792260139768799.davem@davemloft.net>
References: <1378559600-15858-1-git-send-email-dborkman@redhat.com>
	<20130907193557.GB17248@order.stressinduktion.org>
	<522D69FF.9000001@nsn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, mlin@ss.pku.edu.cn
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755701Ab3IKUOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:14:31 -0400
In-Reply-To: <522D69FF.9000001@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Mon, 09 Sep 2013 09:26:07 +0300

> On 09/07/2013 10:35 PM, ext Hannes Frederic Sowa wrote:
>> On Sat, Sep 07, 2013 at 03:13:20PM +0200, Daniel Borkmann wrote:
>>> When the kernel is compiled with CONFIG_IPV6_SUBTREES, and we return
>>> with an error in fn = fib6_add_1(), then error codes are encoded into
>>> the return pointer e.g. ERR_PTR(-ENOENT). In such an error case, we
>>> write the error code into err and jump to out, hence enter the if(err)
>>> condition. Now, if CONFIG_IPV6_SUBTREES is enabled, we check for:
>>>
>>>    if (pn != fn && pn->leaf == rt)
>>>      ...
>>>    if (pn != fn && !pn->leaf && !(pn->fn_flags & RTN_RTINFO))
>>>      ...
>>>
>>> Since pn is NULL and fn is f.e. ERR_PTR(-ENOENT), then pn != fn
>>> evaluates to true and causes a NULL-pointer dereference on further
>>> checks on pn. Fix it, by setting both NULL in error case, so that
>>> pn != fn already evaluates to false and no further dereference
>>> takes place.
>>>
>>> This was first correctly implemented in 4a287eba2 ("IPv6 routing,
>>> NLM_F_* flag support: REPLACE and EXCL flags support, warn about
>>> missing CREATE flag"), but the bug got later on introduced by
>>> 188c517a0 ("ipv6: return errno pointers consistently for
>>> fib6_add_1()").
>>>
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>> Cc: Lin Ming <mlin@ss.pku.edu.cn>
>>> Cc: Matti Vaittinen <matti.vaittinen@nsn.com>
>>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>
>> Full ACK!
>>
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>
> Acked-by: Matti Vaittinen <matti.vaittinen@nsn.com>

Applied, thanks everyone.
