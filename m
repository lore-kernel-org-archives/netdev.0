From: Jay Rouman <jsr@dex.edzone.net>
Subject: Re: LInux kernel 3.0 sit creation bug report
Date: Sun, 24 Jul 2011 11:40:35 -0400 (EDT)
Message-ID: <E1Ql0nD-0000YW-9R@dex.edzone.net>
References: <1311496931.6669.16.camel@edumazet-laptop>
Reply-To: jsr@dex.edzone.net
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dex.edzone.net ([207.74.88.2]:57884 "EHLO dex.edzone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802Ab1GXPkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 11:40:39 -0400
In-Reply-To: <1311496931.6669.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got the route2 configuration to work.  Sorry for the bother.  There
does seem to be a change in behavior as noted between 2.6.39 and 3.0
when using ifconfig and sit0.  Perhaps this was intended.

--Jay Rouman

> Le samedi 23 juillet 2011 ? 12:27 -0400, Jay Rouman a ?crit :
> > Kernel 3.0 (release version)
> > Summary:  sit tunnel creation fails with "No buffer space available"
> > 
> > Example:
> > 
> > icebox:/home/u/jsr(3)# /sbin/ip tunnel add sit0 mode sit local 216.111.203.89 remote 209.51.18.1 ttl 255
> > add tunnel sit0 failed: No buffer space available
> > 
> > icebox:/home/u/jsr(8)# /sbin/ifconfig sit0 inet6 tunnel ::209.51.18.1
> > SIOCSIFDSTADDR: No buffer space available
> > 
> > Notes:
> > 
> > Oddly, the ifconfig example creates a working sit0.  The "ip" example
> > does not.  The problem existed in rc1 but unfortunately I did not test
> > sit creation then.  This was discovered when I upgraded a machine with
> > an HE tunnel to the 3.0 kernel.  I am happy to do further testing or
> > provide whatever additional info I can.
> > 
> 
> I believe you use a deprecated (~10 years ago ?) way to setup your
> tunnel, its not a linux-3.0 new behavior.
> 
> sit0 is reserved (fall back tunnel), you should use a different name.
> 
> Try :
> 
> # ip tunnel add aster mode sit local 216.111.203.89 remote 209.51.18.1 ttl 255
> # ifconfig aster up
> 
> # ip tunnel
> sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc
> aster: ipv6/ip  remote 209.51.18.1  local 216.111.203.89  ttl 255 
