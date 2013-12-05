From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable memory mapped
 netlink i/o
Date: Thu, 05 Dec 2013 23:08:31 +0100
Message-ID: <52A0F95F.4010402@redhat.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com> <20131204163328.GE30874@nicira.com> <529F6475.3090903@redhat.com> <20131204180818.GB16940@nicira.com> <529FA334.4050202@redhat.com> <CAEP_g=8jMEsrOEpU=LTsfp93RaOowR5DfRB=dzQ-OJEsAVmm0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54501 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871Ab3LEWqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 17:46:42 -0500
In-Reply-To: <CAEP_g=8jMEsrOEpU=LTsfp93RaOowR5DfRB=dzQ-OJEsAVmm0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2013 11:20 PM, Jesse Gross wrote:
> If enabling rings on demand can be done cleanly that might be best
> solution. To me, it seems difficult to generalize the upcall
> characteristics based on port type.

It would require to reopen sockets but I don't see that as a major
obstacle.

> 16K ports/sockets would seem to be a good upper bound. However, there
> are a couple of factors that might affect that number in the future.
> The first is that port might not be fine-grained enough - for example,
> on an uplink port it would be better to look at MAC or IP address to
> enforce fairness, which would tend to expand the number of sockets
> necessary (although there obviously won't be a 1:1 mapping, which
> means that we might have to come up with a more clever assignment
> algorithm). The second is that Alex has been working on a userspace
> mechanism for enforcing fairness (you probably have seen his recent
> patches on the mailing list), which could reduce the number of unique
> queues from the kernel.

Let's see where we get to with the on demand idea. Defaulting to on
is sitll possible if the number of sockets can be limited again.
