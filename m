From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: SCTP_SOCKOPT_PEELOFF return socket pointer
 for kernel users
Date: Fri, 10 Jul 2015 18:21:14 -0700 (PDT)
Message-ID: <20150710.182114.1532697560595947999.davem@davemloft.net>
References: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbbGKGKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:10:30 -0400
In-Reply-To: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu,  9 Jul 2015 11:15:19 -0300

> SCTP has this operation to peel off associations from a given socket and
> create a new socket using this association. We currently have two ways
> to use this operation:
> - via getsockopt(), on which it will also create and return a file
>   descriptor for this new socket
> - via sctp_do_peeloff(), which is for kernel only
> 
> The caveat with using sctp_do_peeloff() directly is that it creates a
> dependency to SCTP module, while all other operations are handled via
> kernel_{socket,sendmsg,getsockopt...}() interface. This causes the
> kernel to load SCTP module even when it's not directly used
> 
> This patch then updates SCTP_SOCKOPT_PEELOFF so that for kernel users of
> this protocol it will not allocate a file descriptor but instead just
> return the socket pointer directly.
> 
> If called by an user application it will work as before.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

I do not like this at all.

Socket option implementations should not change their behavior or what
datastructures they consume or return just because the socket happens
to be a kernel socket.

I'm not applying this series, sorry.

Also, your patch series lacked an intial "PATCH 0/N" posting, so you
could at least spend the time to discuss this patch series at a high
level and explain your overall motivations.
