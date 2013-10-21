From: Jimmy PERCHET <jimmy.perchet@parrot.com>
Subject: Re: [PATCH RFC 5/5] net:stmmac: asynchronous tx_clean
Date: Mon, 21 Oct 2013 20:05:21 +0200
Message-ID: <52656CE1.1060703@parrot.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>  <1381937052-8999-6-git-send-email-jimmy.perchet@parrot.com>  <5265318C.5050307@st.com> <1382373005.3284.61.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>, Jimmy Perchet <jimmy.perchet@parrot.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:39376 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab3JUSFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 14:05:15 -0400
In-Reply-To: <1382373005.3284.61.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/2013 18:30, Eric Dumazet wrote:
> On Mon, 2013-10-21 at 15:52 +0200, Giuseppe CAVALLARO wrote:
>> Hello Jimmy
>>
>> On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
>>> Tx descriptor's cleanup and preparation are serialized, which is not necessary
>>> and decrease performance.
>>> In addition TX descriptor's cleanup is performed on NET_RX softirq, this is
>>> confusing.
>>
>> hmm, here you are changing the logic behind the tx/rx processes.
>>
>> As done in many drivers, the stmmac cleans the tx resources in
>> NAPI context and this is not a confuse approach ;-).
>>
>> It gave me some performance improvements especially on TCP benchmarks.
>>
>>> This patch unserialize tx descriptor's cleanup and preparation
>>> and defer cleanup in workqueue.
>>
>> So you decide to use workqueue and I kindly ask you to give me more
>> details about the performance improvements (UDP/TCP) and cpu usage.
>>
>> I can try to do some tests on my side too. This could take a while
>> unfortunately.
> 
> Anyway this patch is buggy.
> 
> 1) Removing tx_lock spinlock in TX completion adds a race in
> stmmac_xmit()
> 
> 2) Generally speaking, we should not rely on a work queue to perform TX
> completions.
> 
> Think about being flooded by incoming frames.
> 
> Work queue could never be scheduled.
> 
> 
I understand your point. Nevertheless I think it is still possible
to avoid serialization, and therefore increase performance, even if
completions must remain in softirq. What do you think ?

In my patch I tried to avoid any race condition. (by updating both
descriptor's cursors only once, for instance)
Could you explain the possible race you see ?

Best Regards,
Jimmy
