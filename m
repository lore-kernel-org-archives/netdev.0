From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] packet: respect devices with LLTX flag in direct
 xmit
Date: Fri, 28 Mar 2014 22:13:40 +0100
Message-ID: <5335E604.4020105@redhat.com>
References: <1395934710-29182-1-git-send-email-dborkman@redhat.com> <20140328.165058.1610297081920676758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753192AbaC1VNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 17:13:43 -0400
In-Reply-To: <20140328.165058.1610297081920676758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2014 09:50 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 27 Mar 2014 16:38:30 +0100
>
>> Quite often it can be useful to test with dummy or similar
>> devices as a blackhole sink for skbs. Such devices are only
>> equipped with a single txq, but marked as NETIF_F_LLTX as
>> they do not require locking their internal queues on xmit
>> (or implement locking themselves). Therefore, rather use
>> HARD_TX_{UN,}LOCK API, so that NETIF_F_LLTX will be respected.
>>
>> trafgen mmap/TX_RING example against dummy device with config
>> foo: { fill(0xff, 64) } results in the following performance
>> improvements for such scenarios on an ordinary Core i7/2.80GHz:
>   ...
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>
> Applied, nice work.
>
> The only remaining issue is that Eric seems to suggest that a tx
> dropped counter bump should be added.  Please submit that as a
> follow-on if my reading of his feedback is accurate.

Yes, will do next week. I think at time of submission we didn't
have that yet. :)
