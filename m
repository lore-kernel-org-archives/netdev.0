From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] neigh: fix a possible leak issue of neigh entry
Date: Wed, 13 May 2015 18:32:37 +0800
Message-ID: <55532845.8010709@windriver.com>
References: <1431495814-22759-1-git-send-email-ying.xue@windriver.com> <1431498048.566.131.camel@edumazet-glaptop2.roam.corp.google.com> <5552FC4D.3060200@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50536 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933479AbbEMKeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 06:34:03 -0400
In-Reply-To: <5552FC4D.3060200@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2015 03:25 PM, Ying Xue wrote:
> On 05/13/2015 02:20 PM, Eric Dumazet wrote:
>> Have you hit this condition ?
>>
> 
> No, I just found the issue when I was reading the code.
> 
>> If yes, there is a bug elsewhere and we need to fix it, not trying to
>> recover.
>>

After a search, it's found your mentioned bug probably should be:

https://patchwork.ozlabs.org/patch/458112/

But I think the bug should be a different issue that the patch is to be
resolved. When the bug happened, neigh_add_timer() would take a reference on an
object that already had a refcount of zero, which means somebody already
decreased the refcount to zero before neigh_add_timer() was called. So, the bug
should be unrelated to neigh_add_timer() although the bug really needs to be
fixed. But the issue the patch tries to fix is wrong because it obviously
violates the generic usage of how to take an object refcount in the object's
timer handler as well as when its timer is started or deleted. Specially when a
neighbour's timer to be modified is in pending state, we should not take its
refcount, otherwise, the neighbour is leaked forever.

Therefore, the patch is needed for us even if your mentioned bug is not fixed.

Regards,
Ying

> 
> Sorry, I don't know its relevant story, so can you please give some hints?
> 
> Thanks,
> Ying
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
