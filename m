From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5 (resend)] net: Make ifindex generation per-net
 namespace (v2)
Date: Tue, 07 Aug 2012 15:13:12 +0200
Message-ID: <1344345192.28967.88.camel@edumazet-glaptop>
References: <501FD0F2.4040609@parallels.com> <501FD15F.70604@parallels.com>
	 <5020F5C3.8010107@parallels.com>
	 <1344341466.28967.78.camel@edumazet-glaptop>
	 <50210C23.2070203@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64796 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638Ab2HGNNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 09:13:18 -0400
Received: by bkwj10 with SMTP id j10so1439324bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 06:13:17 -0700 (PDT)
In-Reply-To: <50210C23.2070203@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 16:37 +0400, Pavel Emelyanov wrote:
> >> @@ -62,6 +62,7 @@ struct net {
> >>  	struct sock 		*rtnl;			/* rtnetlink socket */
> >>  	struct sock		*genl_sock;
> >>  
> >> +	int			ifindex;
> > 
> > could you place ifindex right after dev_base_seq : avoid two holes
> > and use the same cache line, dirtied in
> > list_netdevice()/unlist_netdevice()
> 
> Sure! Here it is:
> 
> From: Pavel Emelyanov <xemul@parallels.com>
> Subject: [PATCH 4/5] net: Make ifindex generation per-net namespace
> 
> Strictly speaking this is only _really_ required for checkpoint-restore to
> make loopback device always have the same index.
> 
> This change appears to be safe wrt "ifindex should be unique per-system"
> concept, as all the ifindex usage is either already made per net namespace
> of is explicitly limited with init_net only.
> 
> There are two cool side effects of this. The first one -- ifindices of
> devices in container are always small, regardless of how many containers
> we've started (and re-started) so far. The second one is -- we can speed
> up the loopback ifidex access as shown in the next patch.
> 
> v2: Place ifindex right after dev_base_seq : avoid two holes and use the
>     same cache line, dirtied in list_netdevice()/unlist_netdevice()
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
Acked-by: Eric Dumazet <edumazet@google.com>
