From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 23:55:48 +0100
Message-ID: <32d8cfdb-b49c-6681-4a51-5d7f08dda391@stressinduktion.org>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201135508.GB24547@oracle.com>
 <CALx6S35DCyi_2z1pqCLaB1bVyNykP_J3YaYEXUT8xxmuzyBDwA@mail.gmail.com>
 <20161201201324.GJ24547@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60590 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752480AbcLAWzv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 17:55:51 -0500
In-Reply-To: <20161201201324.GJ24547@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.12.2016 21:13, Sowmini Varadhan wrote:
> On (12/01/16 11:05), Tom Herbert wrote:
>>
>> Polling does not necessarily imply that networking monopolizes the CPU
>> except when the CPU is otherwise idle. Presumably the application
>> drives the polling when it is ready to receive work.
> 
> I'm not grokking that- "if the cpu is idle, we want to busy-poll
> and make it 0% idle"?  Keeping CPU 0% idle has all sorts
> of issues, see slide 20 of
>  http://www.slideshare.net/shemminger/dpdk-performance
>
>>> and one other critical difference from the hot-potato-forwarding
>>> model (the sort of OVS model that DPDK etc might aruguably be a fit for)
>>> does not apply: in order to figure out the ethernet and IP headers
>>> in the response correctly at all times (in the face of things like VRRP,
>>> gw changes, gw's mac addr changes etc) the application should really
>>> be listening on NETLINK sockets for modifications to the networking
>>> state - again points to needing a select() socket set where you can
>>> have both the I/O fds and the netlink socket,
>>>
>> I would think that that is management would not be implemented in a
>> fast path processing thread for an application.
> 
> sure, but my point was that *XDP and other stack-bypass methods needs 
> to provide a select()able socket: when your use-case is not about just
> networking, you have to snoop on changes to the control plane, and update
> your data path. In the OVS case (pure networking) the OVS control plane
> updates are intrinsic to OVS. For the rest of the request/response world,
> we need a select()able socket set to do this elegantly (not really
> possible in DPDK, for example)

Busypoll on steroids is what windows does by mapping the user space
"doorbell" into a vDSO and let user space loop on that maybe with
MWAIT/MONITOR. The interesting thing is that you can map other events to
this notification event, too. It sounds like a usable idea to me and
reassembles what we already do with futexes.

Bye,
Hannes
