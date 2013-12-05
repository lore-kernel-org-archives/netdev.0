From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable memory mapped
 netlink i/o
Date: Thu, 5 Dec 2013 14:54:26 -0800
Message-ID: <20131205225426.GB18056@nicira.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
 <20131204163328.GE30874@nicira.com>
 <529F6475.3090903@redhat.com>
 <20131204180818.GB16940@nicira.com>
 <529FA334.4050202@redhat.com>
 <CAEP_g=8jMEsrOEpU=LTsfp93RaOowR5DfRB=dzQ-OJEsAVmm0g@mail.gmail.com>
 <52A0F95F.4010402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:41395 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751139Ab3LEWyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 17:54:33 -0500
Received: by mail-qe0-f46.google.com with SMTP id a11so18162029qen.33
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 14:54:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52A0F95F.4010402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 11:08:31PM +0100, Thomas Graf wrote:
> On 12/04/2013 11:20 PM, Jesse Gross wrote:
> >If enabling rings on demand can be done cleanly that might be best
> >solution. To me, it seems difficult to generalize the upcall
> >characteristics based on port type.
> 
> It would require to reopen sockets but I don't see that as a major
> obstacle.
> 
> >16K ports/sockets would seem to be a good upper bound. However, there
> >are a couple of factors that might affect that number in the future.
> >The first is that port might not be fine-grained enough - for example,
> >on an uplink port it would be better to look at MAC or IP address to
> >enforce fairness, which would tend to expand the number of sockets
> >necessary (although there obviously won't be a 1:1 mapping, which
> >means that we might have to come up with a more clever assignment
> >algorithm). The second is that Alex has been working on a userspace
> >mechanism for enforcing fairness (you probably have seen his recent
> >patches on the mailing list), which could reduce the number of unique
> >queues from the kernel.
> 
> Let's see where we get to with the on demand idea. Defaulting to on
> is sitll possible if the number of sockets can be limited again.

This seems reasonable to me.

I'm not looking for perfection here, by the way, in terms of which
sockets get mmaped and which don't.  I'll be happy with any reasonable
heuristic to start out, we can always improve it later.
 
