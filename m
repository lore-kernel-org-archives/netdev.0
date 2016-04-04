From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Mon, 4 Apr 2016 16:18:38 +0100
Message-ID: <570285CE.8060803@solarflare.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
 <57022A85.6040002@iogearbox.net> <20160404150700.1456ae80@redhat.com>
 <1459780420.6473.337.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Brenden Blanco <bblanco@plumgrid.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <tom@herbertland.com>,
	<alexei.starovoitov@gmail.com>, <gerlitz@mellanox.com>,
	<john.fastabend@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:6522 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752590AbcDDPSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 11:18:55 -0400
In-Reply-To: <1459780420.6473.337.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/16 15:33, Eric Dumazet wrote:
> On Mon, 2016-04-04 at 15:07 +0200, Jesper Dangaard Brouer wrote:
> 
>> Argh... maybe the minimal pseudo/fake SKB is the wrong "signal" to send
>> to users of this API.
>>
>> The hole idea is that an SKB is NOT allocated yet, and not needed at
>> this level.  If we start supporting calling underlying SKB functions,
>> then we will end-up in the same place (performance wise).
> 
> A BPF program can access many skb fields.
> 
> If you plan to support BPF, your fake skb needs to be populated like a
> real one. Looks like some code will be replicated in all drivers that
> want this facility...
> 
> Or accept (document ?) that some BPF instructions are just not there.
> (hash, queue_mapping ...)

If these progs are eventually going to get pushed down into supporting
hardware, many skb things won't make sense at all at that level.  I would
suggest that anything hardware wouldn't reasonably have available should
be "just not there"; I suspect that'll lead you to the right API for early
driver filter as well.  And it probably won't look much like an skb.

-Ed
