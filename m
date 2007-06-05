From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Socket hangs in read() when putting interface down
Date: Tue, 05 Jun 2007 10:41:51 -0700
Message-ID: <4665A05F.9080600@hp.com>
References: <46657D21.3010203@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chris schlund <chrisschlund@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:40896 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873AbXFERlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 13:41:52 -0400
In-Reply-To: <46657D21.3010203@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

chris schlund wrote:
> Using read() on a socket(AF_INET, SOCK_STREAM) connected via any network
> interface (e.g eth0) and putting this interface down (ifconfig) while
> the socket is in read() produces a hanger (the read() will not return
> anymore).
> Even if I install sigaction signal handler I got no signal when the
> interface is removed.

I'd not think there was a direct tie-in between an application signal 
handler and an interface being downed.

> This may be ok on a major interface like eth0 but it is a problem when
> using a ppp interface via GSM data or GPRS connection.
> Killing the pppd while the socket waits in read() produces the same
> behaviour. Also a broken connection looks the same.
> It is reproducable on several 2.6 kernel versions including the lastest
> stable 2.6.21.
> 
> On my understanding "ifconfig down" should lead into a read() error.

Why?  Can't traffic for the endpoint arrive via some other interface on 
the system?  I would think that getting out of a blocking read() 
requires the application to either have a timer running (and so get out 
of read() with EINTR) or to have keepalives enabled on the TCP 
connection (I'm assuming TCP for an AF_INET, SOCK_STREAM although I 
suppose it could be SCTP)

rick jones
