From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH 2/2] tcp: fix FIN_WAIT2 timer expression in /proc/net/tcp
Date: Fri, 15 Feb 2013 17:26:18 +0900
Message-ID: <1360916778.3463.26.camel@ubuntu-vm-makita>
References: <1360673384.10638.10.camel@ubuntu-vm-makita>
	 <1360673521.10638.12.camel@ubuntu-vm-makita>
	 <1360673668.10638.14.camel@ubuntu-vm-makita>
	 <1360681070.13993.2.camel@edumazet-glaptop>
	 <1360682002.13993.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:54309 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab3BOI0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 03:26:31 -0500
In-Reply-To: <1360682002.13993.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 07:13 -0800, Eric Dumazet wrote:
> On Tue, 2013-02-12 at 06:57 -0800, Eric Dumazet wrote:
> 
> > I find this patch confusing :
> > 
> > 1) Please don't change the indentation for a bug fix

OK, I will separate changes of indentation to another patch.

> > 
> > 2) You add a new 'active=3' field, that some user space
> > reading /proc/net/tcp wont expect.

I think, at least, it's harmless and beneficial for netstat.
Even without this change, a keepalive timer of an orphaned
FIN_WAIT2 socket will eventually turn to a timewait timer, 
and by default, or when tcp_fin_timeout is 60, there will be
only timewait timers for orphaned FIN_WAIT2.
If the socket is not closed and SO_KEEPALIVE is set, 
a keepalive timer of FIN_WAIT2 will also be shown in
/proc/net/tcp, whose state isn't equal to above one.
I don't know any application that will be damaged with this
change, and I think the possibility that this change affects
a bad influence to userspace is low.
Please advise.

> > 
> > So the changelog is not matching the changes.
> 
> Also, net/ipv4/inet_diag.c was not changed
> 

thank you for pointing out my mistake.
I will correct it, too.


Toshiaki Makita
