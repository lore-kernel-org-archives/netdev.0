From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] vsock: Fix blocking ops call in prepare_to_wait
Date: Wed, 16 Mar 2016 19:19:24 -0400 (EDT)
Message-ID: <20160316.191924.1375803074089875897.davem@davemloft.net>
References: <1457699963-27694-1-git-send-email-imbrenda@linux.vnet.ibm.com>
	<20160314.152403.1490973796884839758.davem@davemloft.net>
	<56E719EA.7040208@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: imbrenda@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, labbott@fedoraproject.org
To: labbott@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E719EA.7040208@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laura Abbott <labbott@redhat.com>
Date: Mon, 14 Mar 2016 13:07:06 -0700

> On 03/14/2016 12:24 PM, David Miller wrote:
>> From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
>> Date: Fri, 11 Mar 2016 13:39:23 +0100
>>
>>> I think I found a problem with the patch submitted by Laura Abbott
>>> ( https://lkml.org/lkml/2016/2/4/711 ): we might miss wakeups.
>>> Since the condition is not checked between the prepare_to_wait and the
>>> schedule(), if a wakeup happens after the condition is checked but
>>> before
>>> the sleep happens, and we miss it. ( A description of the problem can
>>> be
>>> found here: http://www.makelinux.net/ldd3/chp-6-sect-2 ).
>>>
>>> My solution (see patch below) is to shrink the area influenced by
>>> prepare_to_wait, but keeping the fragile section around the condition,
>>> and
>>> keep the rest of the code in "normal" running state.  This way the
>>> sleep is
>>> correct and the other functions don't need to worry.  The only caveat
>>> here
>>> is that the function(s) called to verify the conditions are really not
>>> allowed to sleep, so if you need synchronization in the backend of
>>> e.g.
>>> vsock_stream_has_space(), you should use spinlocks and not mutexes.
>>>
>>> In case we want to be able to sleep while waiting for conditions, we
>>> can
>>> consider this instead: https://lwn.net/Articles/628628/ .
>>>
>>>
>>> I stumbled on this problem while working on fixing the upcoming virtio
>>> backend for vsock, below is the patch I had prepared, with the
>>> original
>>> message.
>>
>> Can someone please look at this?  Who maintains this code anyways?
>>
> 
> Nobody was listed in MAINTAINERS. I tried cc-ing some of the e-mail
> addresses
> of the original authors (vmware?) when sending the original patch and
> they
> all bounced.

Ok, can you please submit this anew?  Your commit message format was
incorrect, you put the commit message content you wanted in the change
after the --- separater instead of beforehand.
