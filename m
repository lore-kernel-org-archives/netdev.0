From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 06 Apr 2009 14:07:34 +0200
Message-ID: <49D9F086.7090905@trash.net>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.679540125@vyatta.com>	<499BDB5D.2050105@trash.net>	<499C1894.7060400@cosmosbay.com>	<49CE568A.9090104@cosmosbay.com>	<20090328174835.0d0b63f8@nehalam>	<49D1241B.6020504@cosmosbay.com> <20090330130532.1e433313@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43297 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755329AbZDFMHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 08:07:41 -0400
In-Reply-To: <20090330130532.1e433313@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 30 Mar 2009 21:57:15 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
>> On normal machines, (no debugging spinlocks), patch uses an embedded
>> spinlock. We probably can use this even on 32bit kernels, considering
>> previous patch removed the rcu_head (8 bytes on 32bit arches) from
>> nf_conn :)
>>
>> if LOCKDEP is on, size of a spinlock is 64 bytes on x86_64.
>> Adding a spinlock on each nf_conn would be too expensive. In this
>> case, an array of spinlock is a good compromise, as done in
>> IP route cache, tcp ehash, ...
>>
>> I agree sizing of this hash table is not pretty, and should be
>> a generic kernel service (I wanted such service for futexes for example)
>>
> 
> IMO having different locking based on lockdep and architecture is an invitation
> to future obscure problems. Perhaps some other locking method or shrinking
> ct entry would be better.

I agree. Do people enable lockdep on production machines? Otherwise
I'd say the size increase doesn't really matter.
