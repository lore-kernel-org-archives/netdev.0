From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Thu, 11 Sep 2008 01:24:13 +0200
Message-ID: <20080910232413.GJ20815@postel.suug.ch>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com> <20080910220115.GH20815@postel.suug.ch> <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com> <6599ad830809101604o71b2fb82k2aca1eb0fd8ab6d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ranjit Manomohan <ranjitm@google.com>, davem@davemloft.net,
	akpm@linux-foundation.org, kaber@trash.net, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44971 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126AbYIJXXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 19:23:54 -0400
Content-Disposition: inline
In-Reply-To: <6599ad830809101604o71b2fb82k2aca1eb0fd8ab6d8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Paul Menage <menage@google.com> 2008-09-10 16:04
> That's a bit different from what Thomas is suggesting (I think).
> 
> There are three options:
> 
> a) socket acquires class id at creation time from its creator task or
> its parent socket. So the class id is fixed for the lifetime of the
> socket
> 
> b) socket acquires a reference to a cgroup at creation time, from its
> creator task or its parent socket. So the class id can be updated by
> changing the cgroup's class id, but the cgroup of the socket can't be
> changed. This can prevent the cgroup from being properly destroyed.
> 
> c) socket acquires a reference to a cgroup at creation time, and can
> be moved to a different cgroup when tasks that reference it move
> between cgroups.
> 
> Our patches use option a. Option c is too heavyweight IMO, and has
> vague semantics for exactly when movement should occur. Option b
> *could* be useful, if you wanted to be able to share class ids between
> cgroups, *and* shuffle the sharing relationships around on the fly. I
> think that Thomas is suggestion option b.

That's right, I had option b) in mind.

> I'm not sure that I see a
> concrete use case for it though - Thomas, what use cases did you see?

Without a) this whole feature is very limited. It requires a process to
be registered to the cgroup before it creates any sockets. Otherwise
these sockets will not have the proper classid value and traffic from
and to this sockets will not be classified. I don't see how this is
practical since many applications create their sockets when the
application is started. F.e. a web browser is causing a bulk data
transfer, admin/user notices this and wants to put it in a restricted
cgroup, won't work.
