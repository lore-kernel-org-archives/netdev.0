From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [Patch 3/3] net: reserve ports for applications using fixed port numbers
Date: Mon, 12 Apr 2010 16:06:54 +0900
Message-ID: <201004120706.o3C76sKG000644@www262.sakura.ne.jp>
References: <20100409101442.5051.99812.sendpatchset@localhost.localdomain>	<20100409101513.5051.97926.sendpatchset@localhost.localdomain> <201004092221.GEE32059.FHMOFVLJOFSOtQ@I-love.SAKURA.ne.jp> <4BC2C34B.50109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, davem@davemloft.net, ebiederm@xmission.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:49939 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0DLHHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 03:07:40 -0400
In-Reply-To: <4BC2C34B.50109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> Tetsuo Handa wrote:
> >> Index: linux-2.6/net/sctp/socket.c
> >> ===================================================================
> >> --- linux-2.6.orig/net/sctp/socket.c
> >> +++ linux-2.6/net/sctp/socket.c
> >> @@ -5436,6 +5436,8 @@ static long sctp_get_port_local(struct s
> >>  			rover++;
> >>  			if ((rover < low) || (rover > high))
> >>  				rover = low;
> >> +			if (inet_is_reserved_local_port(rover))
> >> +				continue;
> > 
> > This one needs to be
> > 
> > 			if (inet_is_reserved_local_port(rover))
> > 				goto next_nolock;
> > 
> >>  			index = sctp_phashfn(rover);
> >>  			head = &sctp_port_hashtable[index];
> >>  			sctp_spin_lock(&head->lock);
> > 
> >  next:
> > 			sctp_spin_unlock(&head->lock);
> > +next_nolock:
> > 		} while (--remaining > 0);
> > 
> > otherwise, it will loop forever if all ports were reserved.
> 
> Sorry, doesn't 'continue' jump to exactly where 'next_nolock' is??
> Or I am missing something?

My misreading, sorry.
