From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Thu, 06 Nov 2014 08:42:59 -0800
Message-ID: <545BA513.2070801@hp.com>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com> <545AD11B.5050603@hp.com> <1415240055.13896.57.camel@edumazet-glaptop2.roam.corp.google.com> <1415241576.13896.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hp.com ([15.217.128.52]:28505 "EHLO
	g2t2353.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbaKFQnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:43:03 -0500
In-Reply-To: <1415241576.13896.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 06:39 PM, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 18:14 -0800, Eric Dumazet wrote:
>> On Wed, 2014-11-05 at 17:38 -0800, Rick Jones wrote:
>>
>>> Speaking of QPS, what happens to 200 TCP_RR tests when the feature is
>>> enabled?
>
> The possible reduction of QPS happens when you have a single flow like
> TCP_RR  -- -r 40000,40000
>
> (Because we have one single TCP packet with 40000 bytes of payload,
> application is waked up once when Push flag is received)
>
> So cpu effiency is way better, but application has to copy 40000 bytes
> in one go _after_ Push flag, instead of being able to copy part of the
> data _before_ receiving the Push flag.

Thanks.  That isn't too unlike what I've seen happen in the past with 
say an 8K request size and switching back and forth between a 1500 and 
9000 byte MTU.

happy benchmarking,

rick
