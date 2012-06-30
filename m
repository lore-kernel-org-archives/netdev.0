From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: Re: AF_BUS socket address family
Date: Sat, 30 Jun 2012 01:09:54 +0100
Message-ID: <20120630000954.GB11480@kyllikki.org>
References: <20120629231236.GA28593@mail.collabora.co.uk>
 <20120629.161821.948325645333976311.davem@davemloft.net>
 <20120629234230.GA11480@kyllikki.org>
 <20120629.165023.1605284574408858612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120629.165023.1605284574408858612.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2012 at 04:50:23PM -0700, David Miller wrote:
> From: Vincent Sanders <vincent.sanders@collabora.co.uk>
> Date: Sat, 30 Jun 2012 00:42:30 +0100
> 
> > Basically you are indicating you would be completely opposed to any
> > mechanism involving D-Bus IPC and the kernel? 
> 
> I would not oppose existing mechanisms, which I do not believe is
> impossible to use in your scenerio.
> 

You keep saying that yet have offered no concrete way to achive the
semantics we require. To pass fd and credentials currently *requires*
the use of AF_UNIX does it not? And D-Bus already emulates its IPC
over AF_UNIX because of that.

> What you really don't get is that packet drops and event losses are
> absolutely fundamental.

not within an IPC surely? there cannot be packet drops within AF_BUS
we simply do not do it. The rrecive queues are checked for capability
of reciving the message before it is delivered to them all or none.

> 
> As long as receivers lack infinite receive queue this will always be
> the case.

Indeed, I would not question that.

> 
> Multicast operates in non-reliable transports only so that one stuck
> or malfunctioning receiver doesn't screw things over for everyone nor
> unduly brudon the sender.
> 

We have addressed this within AF_BUS by the reciver and bus master
being told if all recepients cannot receive the message (and therefor
it cannot be sent). 

The policy decision of how to handle this situation is therefore
handled by the userspace clients on a protocol level. D-Bus *already*
has to handle this situation, its just currently done over AF_UNIX
sockets so once it occours the problem is harder to rectify as the
ordering constraint is broken (which causes even more issues).

I am afraid it is rather late here and I may not be able to continue
this conversation untill the morning, I apologise if this is
inconveniant, but I must sleep.

-- 
Regards Vincent
