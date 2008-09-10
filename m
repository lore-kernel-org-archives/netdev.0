From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/2] Traffic control cgroups subsystem
Date: Thu, 11 Sep 2008 00:12:06 +0200
Message-ID: <20080910221206.GI20815@postel.suug.ch>
References: <Pine.LNX.4.64.0809101026190.7050@ranjit.corp.google.com> <20080910.132251.73509521.davem@davemloft.net> <166fe7950809101344l7a5e2b7pfba8b2a7c03814a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	akpm@linux-foundation.org, lizf@cn.fujitsu.com, menage@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43395 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068AbYIJWLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 18:11:47 -0400
Content-Disposition: inline
In-Reply-To: <166fe7950809101344l7a5e2b7pfba8b2a7c03814a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-09-10 13:44
> On Wed, Sep 10, 2008 at 1:22 PM, David Miller <davem@davemloft.net> wrote:
> >
> > I definitely prefer Thomas Graf's work, this stuff is very ugly
> > and way overengineered.
> >
> 
> Could you be more specific? Thomas' work is almost identical to this
> (except that he does not store the cgroup id into the socket which is
> a trivial change which has downsides which I have pointed out).
> 
> Additionally this approach has only minor modifications to the core
> networking stack. What portions do you consider ugly and over
> engineered and what alternative implementations would you prefer?
> Please see the follow up I have sent to Thomas' proposal about why we
> need this design approach to handle the inbound case.

WRT the inbound case, after some experiments I decided to dismiss the
ingress case at all and stick to something as simple as possible for
egress. The reason for this is that it is a very expensive operation
to associate a packet with a task on classifier level. Taking this
cost, it does not add up with the very limited capabilities of ingress
shaping. Ingress shaping is best effort at best. It works fairly well
with a very limited number of bulk data streams but usualy fails
miserably in common congestion situations where a cgroup classifier
would be useful.

> I'd be ok if you accepted either change since  we just want a standard
> kernel mechanism to do this.

Agreed. I think your approach is very reasonable but considering the
reasons I've given above and in the other thread I found it could be done
in a more simple and direct way.
