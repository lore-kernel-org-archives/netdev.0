From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 04:55:47 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609.045547.91327851.davem@redhat.com>
References: <000401c32e5e$a707b6d0$4a00000a@badass>
	<20030609072227.R34462@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030609072227.R34462@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Mon, 9 Jun 2003 07:38:44 -0400 (EDT)

   Yes, you have a nice setup and thats why you should test all the patches
   DaveM is posting. Dave, Paul is running in a real ISP environment i think
   he is very valuable in helping to test these patches and collect
   any says that might be needed. Now watch him disapear ;->
   
If he doesn't test my patches he isn't very useful,
so we'll see :-)

   Additional thought Dave: i think prefetching the rth would help in 2.5
   at least when you have lotsa collisions.
   call prefetch(nextrth) right after smp_read_barrier_depends() everywhere
   in route.c
   
You're going to prefetch "nextrth" when the first thing we're
going to access is "&nextrth->fl"? :-)

It only makes sense to prefetch the 'fl' member of the first hash
chain entry and that's what I've done in my tree.  This points out
that it would make sense to put the struct flowi up into the dst
entry.
