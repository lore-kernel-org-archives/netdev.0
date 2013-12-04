From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable memory mapped
 netlink i/o
Date: Wed, 04 Dec 2013 22:48:36 +0100
Message-ID: <529FA334.4050202@redhat.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com> <20131204163328.GE30874@nicira.com> <529F6475.3090903@redhat.com> <20131204180818.GB16940@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	dborkman@redhat.com, ffusco@redhat.com, fleitner@redhat.com,
	xiyou.wangcong@gmail.com
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932067Ab3LDVsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 16:48:53 -0500
In-Reply-To: <20131204180818.GB16940@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2013 07:08 PM, Ben Pfaff wrote:
> On Wed, Dec 04, 2013 at 06:20:53PM +0100, Thomas Graf wrote:
>> How about we limit the number of mmaped sockets to a configurable
>> maximum that defaults to 16 or 32?
>
> Maybe you mean that we should only mmap some of the sockets that we
> create.  If so, this approach is reasonable,

Yes, that's what I meant.

> if one can come up with a
> good heuristic to decide which sockets should be mmaped.  One place
> one could start would be to mmap the sockets that correspond to
> physical ports.

That sounds reasonable, e.g. I would assume ports connected to tap
devices to produce only a limited number of upcalls anyway.

We can also consider enabling/disabling mmaped rings on demand based
on upcall statistics.

> Maybe you mean that we should only create 16 or 32 Netlink sockets,
> and divide the datapath ports among those sockets.  OVS once used this
> approach.  We stopped using it because it has problems with fairness:
> if two ports are assigned to one socket, and one of those ports has a
> huge volume of new flows (or otherwise sends a lot of packets to
> userspace), then it can drown out the occasional packet from the other
> port.  We keep talking about new, more flexible approaches to
> achieving fairness, though, and maybe some of those approaches would
> allow us to reduce the number of sockets we need, which would make
> mmaping all of them feasible.

I can see the fairness issue. It will result in a large amount of open
file descriptors though. I doubt this will scale much beyond 16K ports,
correct?
