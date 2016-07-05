From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Tue, 05 Jul 2016 09:44:00 -0500
Message-ID: <87twg4ywjz.fsf@x220.int.ebiederm.org>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56275 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932923AbcGEO5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 10:57:00 -0400
In-Reply-To: <1467729773-16751-1-git-send-email-phil@nwl.cc> (Phil Sutter's
	message of "Tue, 5 Jul 2016 16:42:51 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Sutter <phil@nwl.cc> writes:

> Stress-testing OpenStack Neutron revealed poor performance of 'ip netns'
> when dealing with a high amount of namespaces. The cause of this lies in
> the combination of how iproute2 mounts NETNS_RUN_DIR and the netns files
> therein and the fact that systemd makes all mount points of the system
> shared.

So please tell me.  Given that it was clearly a deliberate choice in the
code to make these directories shared, and that this is not a result
of a systemd making all directories shared by default.  Why is it
better to these directories non-shared?

This may be the appropriate change but saying you stress testing things
and have a problem but do not describe how large a scale you had a
problem, or anything else to make your problem reproducible by anyone
else makes it difficult to consider the merits of this change.

Sometimes things are a good default policy but have imperfect scaling on
extreme workloads.

My experience with the current situtation with ip netns is that it
prevents a whole lot of confusion by making the network namespace names
visible whichever mount namespace your processes are running in.

> Phil Sutter (2):
>   ipnetns: Move NETNS_RUN_DIR into it's own propagation group
>   ipnetns: Make netns mount points private
>
>  ip/ipnetns.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)

Eric
