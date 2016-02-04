From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Disabling XPS for 4.4.0-1+ixgbe+OpenStack VM over a VLAN means
 65% increase in netperf TCP_STREAM
Date: Thu, 4 Feb 2016 12:28:09 -0800
Message-ID: <56B3B459.5040204@hpe.com>
References: <56B3A2D4.1010309@hpe.com>
 <CALx6S36PxgZufhFa4qChPJvW0eb1V_fQoQOH7HHKd4q00taR=A@mail.gmail.com>
 <56B3AD3F.9070404@hpe.com>
 <CALx6S37CekHutCQaXacpqKMSag971_GnHBZQTSE-DwU1tbt1RA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5009.houston.hp.com ([15.240.92.67]:43929 "EHLO
	g9t5009.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932861AbcBDU2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 15:28:11 -0500
In-Reply-To: <CALx6S37CekHutCQaXacpqKMSag971_GnHBZQTSE-DwU1tbt1RA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2016 12:13 PM, Tom Herbert wrote:
> On Thu, Feb 4, 2016 at 11:57 AM, Rick Jones <rick.jones2@hpe.com> wrote:
>> On 02/04/2016 11:38 AM, Tom Herbert wrote:
>>> XPS has OOO avoidance for TCP, that should not be a problem.
>>
>>
>> What/how much should I read into:
>>
>> With XPS    TCPOFOQueue: 78206
>> Without XPS TCPOFOQueue: 967
>>
>> out of the netstat statistics on the receiving VM?
>>
> Okay, that makes sense. The OOO avoidance only applies to TCP sockets
> in the stack, that doesn't cross into VM. Presumably, packets coming
> from the VM don't have a socket so sk_tx_queue_get always returns -1
> and so netdev_pick_tx will steer packet to the queue based on
> currently running CPU without any memory.

Any thoughts as to why explicitly binding the IRQs made things better, 
or for that matter why the scheduler would be moving the VM (or its 
vhost-net kernel thread I suppose?) around so much?

happy benchmarking,

rick jones
