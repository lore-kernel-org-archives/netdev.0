From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 1 Apr 2016 06:12:49 +0200
Message-ID: <56FDF541.6070106@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401014516.GA11017@ast-mbp.thefacebook.com>
 <1459479818.6473.265.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401040442.GA14661@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net, mkubecek@suse.cz
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:46913 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750741AbcDAEMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 00:12:54 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id F056820A7F
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 00:12:53 -0400 (EDT)
In-Reply-To: <20160401040442.GA14661@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.04.2016 06:04, Alexei Starovoitov wrote:
> On Thu, Mar 31, 2016 at 08:03:38PM -0700, Eric Dumazet wrote:
>> On Thu, 2016-03-31 at 18:45 -0700, Alexei Starovoitov wrote:
>>
>>> Eric, what's your take on Hannes's patch 2 ?
>>> Is it more accurate to ask lockdep to check for actual lock
>>> or lockdep can rely on owned flag?
>>> Potentially there could be races between setting the flag and
>>> actual lock... but that code is contained, so unlikely.
>>> Will we find the real issues with this 'stronger' check or
>>> just spend a ton of time adapting to new model like your other
>>> patch for release_sock and whatever may need to come next...
>>
>> More precise lockdep checks are certainly good, I only objected to 4/4
>> trying to work around another bug.
>>
>> But why do we rush for 'net' tree ?
>>
>> This looks net-next material to me.
>>
>> Locking changes are often subtle, lets take the time to do them
>> properly.
>
> completely agree. I think only first patch belongs in net.
> Everything else is net-next material.

Problem with first patch is that it uses lock_sock_fast, thus the 
current sock_owned_by_user check doesn't get rid the lockdep warning. :/

Thus we would need to go with the two first patches. Do you think it is 
acceptable? I actually didn't see a problem and testing showed no 
problems so far.

Bye,
Hannes
