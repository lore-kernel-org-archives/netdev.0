From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port numbers
Date: Fri, 5 Feb 2010 14:28:12 +0200
Message-ID: <201002051428.12767.opurdila@ixiacom.com>
References: <20100204.094110.64247447.davem@davemloft.net> <201002050305.22227.opurdila@ixiacom.com> <4B6BB447.8080806@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:11565 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755706Ab0BEMbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 07:31:37 -0500
In-Reply-To: <4B6BB447.8080806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 05 February 2010 08:01:43 you wrote:

> >> If you can accept his version, I want to use his version (with an
> >> interface for updating above "reserved_ports" by not only root user's
> >> sysctl() but also MAC's policy configuration).
> >
> > I think that simply using an interface to update the reserved_ports from
> > MAC policy configuration module wouldn't work, as root will be able to
> > modify the policy via sysctl.
> >
> > I think that we might need to:
> >
> > a) have a reserved_port updater
> >
> > b) put a LSM hook into that
> >
> > c) use the reserved_port updater from sysctl
> 
> Ideally, you'd provide an interface for port allocator to use, so
> doing port reservation will be easier.
> 

If I understand the TOMOYO requirements correctly, we need a way to restrict a 
user action based on some security policy (in this case the ability to clear 
reserved ports). Traditionally that has been done with LSM hooks, so I think 
that approach is preferable.
