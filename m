From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 16:45:38 -0400 (EDT)
Message-ID: <20160510.164538.1375529074383780155.davem@davemloft.net>
References: <1462896230.6687.74.camel@redhat.com>
	<1462896539.23934.93.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462911770.5333.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	ast@plumgrid.com, aduyck@mirantis.com, tom@herbertland.com,
	peterz@infradead.org, mingo@kernel.org, riel@redhat.com,
	hannes@stressinduktion.org, linux-kernel@vger.kernel.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbcEJUpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:45:44 -0400
In-Reply-To: <1462911770.5333.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 10 May 2016 22:22:50 +0200

> On Tue, 2016-05-10 at 09:08 -0700, Eric Dumazet wrote:
>> On Tue, 2016-05-10 at 18:03 +0200, Paolo Abeni wrote:
>> 
>> > If a single core host is under network flood, i.e. ksoftirqd is
>> > scheduled and it eventually (after processing ~640 packets) will let the
>> > user space process run. The latter will execute a syscall to receive a
>> > packet, which will have to disable/enable bh at least once and that will
>> > cause the processing of another ~640 packets. To receive a single packet
>> > in user space, the kernel has to process more than one thousand packets.
>> 
>> Looks you found the bug then. Have you tried to fix it ?
 ...
> The ksoftirq and the local_bh_enable() design are the root of the
> problem, they need to be touched/affected to solve it.

That's not what I read from your description, processing 640 packets
before going to ksoftirqd seems to the be the absolute root problem.
