From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 16:54:12 +0400
Message-ID: <20060816125412.GB16917@ms2.inr.ac.ru>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, hasso@estpak.ee, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:35986 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751157AbWHPMzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 08:55:49 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> The netlink header pid is really akin to sadb_msg_pid from RFC 2367.
> IMHO it should always be zero if the kernel is the originator of the
> message.

No. Analogue of sadb_msg_pid is nladdr.nl_pid.


Netlink header pid is not originator of the message, but author of
the change. The notion is ambiguous by definition, and the field
is a little ambiguous.

If the message is a plain ack or part of a dump, it is obviously
pid of requestor. But if it is notification about change, it can be
nl_pid of socket, which requested the operation, but may be 0.
Of course, all the 0s sent only because I was lazy to track authorship,
should be eliminated.

Alexey
