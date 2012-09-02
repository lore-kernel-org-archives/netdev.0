From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: (ipt_log_packet, sb_add) 3.6.0-rc2 kernel panic -
 not syncing; Fatal exception in interrupt
Date: Mon, 03 Sep 2012 01:37:58 +0200
Message-ID: <1346629078.2563.75.camel@edumazet-glaptop>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
	<20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
	<20120902132834.GB7456@breakpoint.cc>
	<1346626385.2563.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Florian Westphal <fw@strlen.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1346626385.2563.44.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2012-09-03 at 00:53 +0200, Eric Dumazet wrote:

> First I thought changing demux to not do the lookup of TIMEWAIT slot in
> __inet_lookup_established(), then it sounds not optimal to redo the full
> lookup for ESTABLISHED sockets later in TCP stack.
> 
> So it seems we should fix xt_LOG instead
> 
> Thanks Florian !
> 
> [PATCH] xt_LOG: take care of timewait sockets
> 
> Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> full blown socket.
> 
> But with TCP early demux, we can have skb->sk pointing to a timewait
> socket.

Seems other fixes are needed, for example in nfnetlink_log.c

I'll send a v2



------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
