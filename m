From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to
 page frag allocators
Date: Tue, 29 Oct 2013 08:30:53 +0100
Message-ID: <526F642D.5010706@redhat.com>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com> <1383002389.4344.7.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Francesco Fusco <ffusco@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476Ab3J2HbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 03:31:06 -0400
In-Reply-To: <1383002389.4344.7.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2013 12:19 AM, Eric Dumazet wrote:
> On Mon, 2013-10-28 at 15:44 -0700, Michael Dalton wrote:
>> The virtio_net driver's mergeable receive buffer allocator
>> uses 4KB packet buffers. For MTU-sized traffic, SKB truesize
>> is > 4KB but only ~1500 bytes of the buffer is used to store
>> packet data, reducing the effective TCP window size
>> substantially. This patch addresses the performance concerns
>> with mergeable receive buffers by allocating MTU-sized packet
>> buffers using page frag allocators. If more than MAX_SKB_FRAGS
>> buffers are needed, the SKB frag_list is used.
>>
>> Signed-off-by: Michael Dalton <mwdalton@google.com>
>> ---
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Daniel & Francesco, this should address the performance problem you
> tried to address with ("tcp: rcvbuf autotuning improvements")

That's awesome, thanks everyone !

> ( http://www.spinics.net/lists/netdev/msg252642.html )
>
> Thanks !
