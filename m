From: Ashwin Rao <ashwin.shirvanthe@gmail.com>
Subject: Re: Restricting payload size in do_tcp_sendpages.
Date: Thu, 1 Mar 2012 23:00:28 +0100
Message-ID: <CAJNbMrxjgwuRopSqJkzXnqWZXwBvKNszMrsu-j9fx8NiA3tYLw@mail.gmail.com>
References: <CAJNbMryYORXmp0CPhL9zt8ne5P5yOKvNLsqnjeNwb4m0OAQeiQ@mail.gmail.com>
	<20120301.160253.995812674096452892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:42936 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069Ab2CAWA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 17:00:28 -0500
Received: by obbuo6 with SMTP id uo6so901220obb.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 14:00:28 -0800 (PST)
In-Reply-To: <20120301.160253.995812674096452892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 1, 2012 at 10:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Ashwin Rao <ashwin.shirvanthe@gmail.com>
> Date: Thu, 1 Mar 2012 16:16:40 +0100
>
>> I would like to perform some experiments where I want TCP to send
>> packets of size less than the MSS even more than an MSS worth of data
>> is available in the TCP buffers.
>
> I think if you are trying to make experimental changes to TCP you
> should be at least skilled enough to implement your ideas fully on
> your own rather than having to ask for a crash course on how the stack
> works.

I am not asking for a crash course on how the stack works. I am trying
to figure out what is wrong with my understanding of the code. I admit
I am not as smart as you guys but then the reason for doing
experiments is because I observed a problem based on the measurement
study that I performed on clusters and home networks. I then worked on
developing a small model to capture the behavior I observed. The
problem I observed has its roots in the synchronization of TCP flows.
This can be addressed by using queuing disciplines like RED but then
it is still a problem in networks that will use off the shelf devices
that use drop-tail queues. The numerical resolutions from the model
predict the behavior that I observed. I am now looking a possible
solutions that can address this issue and I am performing experiments
to see whether my proposed solutions are practically useful or not.
This is because the model cannot capture everything.  What I want to
do is to ensure that the packets arriving in the network do not have
the same size or at least the last packet in a window of packets has a
size smaller than the MSS. This according to the model is enough to
break the synchronization that I observed in the clusters and home
networks. To test this I forcefully set the segment size (and size
goal which controls the size in case of offloading) in the function
do_tcp_sendpages. According to my understanding this is the last point
before which the tcp packet is created before being sent to the lower
layer.

> Frankly, if you aren't skilled enough to figure these things out on
> your own I really don't think you should be even suggesting changes
> to a complicated protocol that effects the entire world.

I may not be skilled enough like you guys but then I am not afraid to
admit I do not know the entire picture. But if there is a problem that
I see and a solution in which I believe in then I will not feel shy of
validating my solution.

Ashwin
