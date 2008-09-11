From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Thu, 11 Sep 2008 02:07:26 +0200
Message-ID: <20080911000726.GM20815@postel.suug.ch>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com> <20080910220115.GH20815@postel.suug.ch> <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com> <6599ad830809101604o71b2fb82k2aca1eb0fd8ab6d8@mail.gmail.com> <20080910232413.GJ20815@postel.suug.ch> <6599ad830809101631q51371f75w2ab9f73ef2414f90@mail.gmail.com> <20080910234523.GK20815@postel.suug.ch> <6599ad830809101651u79a0efb7y8fa7288de6e48c8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ranjit Manomohan <ranjitm@google.com>, davem@davemloft.net,
	akpm@linux-foundation.org, kaber@trash.net, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46083 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbYIKAHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 20:07:08 -0400
Content-Disposition: inline
In-Reply-To: <6599ad830809101651u79a0efb7y8fa7288de6e48c8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Paul Menage <menage@google.com> 2008-09-10 16:51
> On Wed, Sep 10, 2008 at 4:45 PM, Thomas Graf <tgraf@suug.ch> wrote:
> >
> > That's argueable I guess. Likely or not, it doesn't make sense to
> > add such restrictions if not required, especially not when it is
> > trivial to just look at the cgroup of the task directly.
> 
> Isn't a very large fraction of outgoing network traffic driven from
> net_tx_action(), which doesn't execute in the context of the sending
> process? Or am I missing something?

net_tx_action() dequeues from the qdisc. The classification is done
before the packets is enqueued onto the qdisc.

A special case exists when the packets needs to be requeued, in this
case the enqueue() is done in softirq context but it should not invoke
the classifier again if I remember correctly.

> You claimed "In the most common case, the packet is not queued before
> it hits the qdisc so this takes away a lot of complexity and is very
> fast but should still be sufficient.". But is that really true on a
> system where the network is busy? (Which is after all exactly the case
> where you care about accurate traffic accounting/policing)

To my best knowledge it is, otherwise I wouldn't say it. Feel free to
prove me wrong.

F.e. it doesn't work if an ifb device is added to egress between
the user and the cgroup classifier. That's what I mean with common
cases.
