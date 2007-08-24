From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [Devel] [PATCH 1/1] Dynamically allocate the loopback device
Date: Sat, 25 Aug 2007 01:24:29 +0400
Message-ID: <46CF4C8D.9010709@gmail.com>
References: <11879698031215-git-send-email-dlezcano@fr.ibm.com>	<46CEFF83.3040003@gmail.com> <20070824104301.2f4ff34e@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <dlunev@gmail.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:41831 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbXHXVYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:24:06 -0400
Received: by nf-out-0910.google.com with SMTP id g13so715817nfb
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 14:24:03 -0700 (PDT)
In-Reply-To: <20070824104301.2f4ff34e@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

no, and this is important. Loopback is initialized in fs_initcall which
is called sufficiently before module_init.

I have checked the code and do not see initialization order mistakes
right now. But, from now on, maintainer should pay attention for this
unfortunate consequence :(

Regards,
    Den

Stephen Hemminger wrote:
> On Fri, 24 Aug 2007 19:55:47 +0400
> "Denis V. Lunev" <dlunev@gmail.com> wrote:
> 
>> dlezcano@fr.ibm.com wrote:
>>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>>
>>> Doing this makes loopback.c a better example of how to do a
>>> simple network device, and it removes the special case
>>> single static allocation of a struct net_device, hopefully
>>> making maintenance easier.
>>>
>>> Applies against net-2.6.24
>>>
>>> Tested on i386, x86_64
>>> Compiled on ia64, sparc
>> I think that a small note, that initialization order is changed will be
>> good to record. After this, loopback MUST be allocated before any other
>> networking subsystem initialization. And this is an important change.
>>
>> Regards,
>>     Den
> 
> Yes, this code would break when other drivers are directly linked
> in. 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> _______________________________________________
> Devel mailing list
> Devel@openvz.org
> https://openvz.org/mailman/listinfo/devel
> 

