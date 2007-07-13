From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 7990 : Various fixes and cleanups
Date: Fri, 13 Jul 2007 14:57:50 -0400
Message-ID: <4697CB2E.2060500@garzik.org>
References: <20070706095828.GA12270@muff.macqel.be> <4693B615.6010605@garzik.org> <20070713104419.GA32178@ingate.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38748 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759627AbXGMS5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 14:57:53 -0400
In-Reply-To: <20070713104419.GA32178@ingate.macqel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philippe De Muyter wrote:
> On Tue, Jul 10, 2007 at 12:38:45PM -0400, Jeff Garzik wrote:
>> Philippe De Muyter wrote:
>>> This patch
>>> - avoids 7990 blocking when no tx buffer is available,
>> [...]
>>> diff -r 6c0a10cc415a drivers/net/7990.c
>>> --- a/drivers/net/7990.c	Thu Jul  5 16:10:16 2007 -0700
>>> +++ b/drivers/net/7990.c	Fri Jul  6 11:27:20 2007 +0200
>> [...]
>>> @@ -541,9 +546,6 @@ int lance_start_xmit (struct sk_buff *sk
>>>         static int outs;
>>> 	unsigned long flags;
>>>
>>> -        if (!TX_BUFFS_AVAIL)
>>> -                return -1;
>>> -
>>> 	netif_stop_queue (dev);
>>>
>>>         skblen = skb->len;
>>
>> NAK
>>
>> It "avoids" by removing an overrun check in hard_start_xmit that should 
>> not be removed.
> 
> Yup, sorry.
> 
> The real fact is still that this prevents/fixes lance/driver blocking on my
> board, while the tx_timeout mechanism does not succeed at that, and that
> on my board the driver is blocked when we return -1 on !TX_BUFFS_AVAIL.

Note that it should be returning a NETDEV_TX_xxx return value, which may 
be confusing the net stack.  You have to let it know what happened to 
the skb passed to ->hard_start_xmit(), which is normally the 
responsibility of the ->hard_start_xmit() hook to free or queue as 
conditions warrant.

Yeah, you will need to investigate further what's going on here.


> PS : did you apply the rest of the patch ?

No, I don't apply partial patches.  You are welcome to resubmit a patch 
containing the non-controversial changes.  In fact, it's normal and 
encouraged in Linux to submit multiple patches for different logical 
changes.  Splitting cleanups and a TX code path change into two separate 
patches is certainly the best way to go.  If there is a problem, that 
allows users to use 'git bisect' to quickly locate which specific patch 
caused the problem.  If patches are split up properly, good-or-bad 
changes are identified more rapidly.

	Jeff


