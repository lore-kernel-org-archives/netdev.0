From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port numbers
Date: Fri, 5 Feb 2010 03:05:22 +0200
Message-ID: <201002050305.22227.opurdila@ixiacom.com>
References: <20100204.094110.64247447.davem@davemloft.net> <20100204.135639.69720709.davem@davemloft.net> <201002050041.o150fCO8081208@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, amwang@redhat.com,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, linux-sctp@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:30064 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933649Ab0BEBIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 20:08:46 -0500
In-Reply-To: <201002050041.o150fCO8081208@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 05 February 2010 02:41:12 you wrote:
> David Miller wrote:
> > > Octavian Purdila wrote:
> > >> int inet_is_reserved_local_port(int port)
> > >> {
> > >> 	if (test_bit(port, reserved_ports))
> > >> 		return 1;
> > >> 	return 0;
> > >> }
> > >
> > > Above check is exactly what I'm doing in the LSM hook.
> >
> > But his version can be done inline in 2 or 3 instructions.
> >
> > An LSM hook will result in an indirect function call,
> > all live registers spilled to the stack, then all of
> > those reloaded when the function returns.
> >
> > It will be much more expensive.
> 
> If you can accept his version, I want to use his version (with an interface
>  for updating above "reserved_ports" by not only root user's sysctl() but
>  also MAC's policy configuration).
> 

I think that simply using an interface to update the reserved_ports from MAC 
policy configuration module wouldn't work, as root will be able to modify the 
policy via sysctl.

I think that we might need to:

a) have a reserved_port updater

b) put a LSM hook into that

c) use the reserved_port updater from sysctl



