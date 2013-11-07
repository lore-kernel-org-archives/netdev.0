From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 06:39:59 -0800
Message-ID: <527BA63F.7040900@intel.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>  <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com> <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46747 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476Ab3KGOkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 09:40:09 -0500
In-Reply-To: <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/2013 6:20 AM, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 06:11 -0800, Eric Dumazet wrote:
>> On Thu, 2013-11-07 at 17:12 +0400, Anton 'EvilMan' Danilov wrote:
>>> Hello.
>>>
>>> I'm experimenting with high performance linux router with 10G NICs.
>>> On high traffic rates the performance are limited by the lock of root
>>> queue discipline. For avoid impact of locking i've decided to build
>>> QoS scheme over the multiq qdisc.
>>>
>
> Oh well, this is a router.
>
> So I think you need to change the device queue selection so that it only
> depends on your filters / htb classes.
>
> Otherwise flows for a particular 'customer' might be spread on the 8
> queues, so the rate could be 8 * 1Mbit, instead of 1Mbit.
>


With the multiq qdisc you could attach filter to the root qdisc and use
skbedit to set the queue_mapping field,

#tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
	match ip dst 192.168.0.3 \
	action skbedit queue_mapping 3

if you configure the filters to map to the correct classes this would
work.

Or another way would be use mqprio and steer packets to HTB classes
using the skb->priority. The priority can be set by iptables/nftables
or an ingress filter.

.John
