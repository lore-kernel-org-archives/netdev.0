From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Wed, 20 Apr 2011 08:56:09 +0300
Message-ID: <4DAE7579.3020400@cs.helsinki.fi>
References: <bug-33502-10286@https.bugzilla.kernel.org/>	 <20110418153852.153d3ed3.akpm@linux-foundation.org>	 <1303181466.4152.39.camel@edumazet-laptop>	 <1303182557.4152.48.camel@edumazet-laptop>	 <1303183217.4152.49.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104191210011.17888@router.home> <1303244270.2756.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59382 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab1DTF4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 01:56:11 -0400
In-Reply-To: <1303244270.2756.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/11 11:17 PM, Eric Dumazet wrote:
> Le mardi 19 avril 2011 =C3=A0 12:10 -0500, Christoph Lameter a =C3=A9=
crit :
>> On Tue, 19 Apr 2011, Eric Dumazet wrote:
>>
>>>   	}
>>>   }
>>>
>>> -#ifdef CONFIG_CMPXCHG_LOCAL
>>> +#if defined(CONFIG_CMPXCHG_LOCAL)&&  \
>>> +	!defined(CONFIG_KMEMCHECK)&&  !defined(DEBUG_PAGEALLOC)
>>> +#define SLUB_USE_CMPXCHG_DOUBLE
>>> +#endif
>>> +
>>> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>>>   #ifdef CONFIG_PREEMPT
>>>   /*
>> Ugg.. Isnt there some way to indicate to kmemcheck that a speculativ=
e
>> access is occurring?
> Yes, here is a totally untested patch (only compiled here), to keep
> kmemcheck&  cmpxchg_double together.

Looks good to me! Can we get someone to test it as well?
