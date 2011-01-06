From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: POLLPRI/poll() behavior change since 2.6.31
Date: Thu, 6 Jan 2011 14:40:46 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1101061429080.4928@davide-lnx1>
References: <20110106155040.GA27769@libre.l.ngdn.org> <1294332929.3074.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonardo Chiquitto <leonardo.lists@gmail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:42436 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470Ab1AFWkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 17:40:51 -0500
Received: from davide-lnx1.local
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S36C6F2> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Thu, 6 Jan 2011 17:40:52 -0500
In-Reply-To: <1294332929.3074.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Jan 2011, Eric Dumazet wrote:

> Hmm, this is because 	sock_def_readable() uses :
> 
> wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLRDNORM |
> POLLRDBAND);
> 
> So POLLPRI bit is not signaled. 
> 
> I would just add POLLPRI flag in sock_def_readable()
> 
> (Alternatively, define a tcp_def_readable() function to pass POLLPRI
> only if TCP_URG is set, but is it worth the pain for a seldom used
> feature ?)

It would be kinda cleaner though, /me thinks.


- Davide


