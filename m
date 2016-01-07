From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net, sched: add clsact qdisc
Date: Thu, 7 Jan 2016 11:09:35 +0100
Message-ID: <568E395F.8020504@stressinduktion.org>
References: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
 <20160107035334.GA99020@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, john.fastabend@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59871 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750707AbcAGKJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 05:09:39 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id C4CC920F7B
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 05:09:38 -0500 (EST)
In-Reply-To: <20160107035334.GA99020@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel and Alexei,

On 07.01.2016 04:53, Alexei Starovoitov wrote:
> On Wed, Jan 06, 2016 at 02:00:56AM +0100, Daniel Borkmann wrote:
>>
>> I decided to extend the sch_ingress module with clsact functionality so
>> that commonly used code can be reused, the module is being aliased with
>> sch_clsact so that it can be auto-loaded properly. Alternative would have been
>> to add a flag when initializing ingress to alter its behaviour plus aliasing
>> to a different name (as it's more than just ingress). However, the first would
>> end up, based on the flag, choosing the new/old behaviour by calling different
>> function implementations to handle each anyway, the latter would require to
>> register ingress qdisc once again under different alias. So, this really begs
>> to provide a minimal, cleaner approach to have Qdisc_ops and Qdisc_class_ops
>> by its own that share callbacks used by both.
> ...
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> we've been going back and forth on the design and this final approach
> presented seems to be the best, since pros outweigh the cons.
>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

One question:

With the advance in lockless qdiscs by John Fastabend, is it possible to 
push the handle_egress hook further down into sched layer?

Bye,
Hannes
