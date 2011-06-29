From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] sctp: Enforce maximum retransmissions during shutdown
Date: Wed, 29 Jun 2011 10:36:49 -0400
Message-ID: <20110629143649.GC10085@canuck.infradead.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:40660 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab1F2Ogw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 10:36:52 -0400
Content-Disposition: inline
In-Reply-To: <4E0B3491.1060603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 10:20:01AM -0400, Vladislav Yasevich wrote:
> I think in this particular case, the receiver has to terminate, not the sender.
> Look at how tcp_close() handles this.
> 
> As long as receiver is available, the sender should continue to try
> sending data.

The receiver does not know that the sender wishes to shutdown the
association. No shutdown request has been sent yet.

I don't think we should be relying on the behaviour of the sender for
the receiver to be able to ever free its ressources. We will be
retransmitting data and keeping an association alive _forever_ for no
purpose.

If there is no reliable way of _ever_ doing a graceful shutdown then
the only alternative is to just ABORT in the first place.

The difference in TCP is that we can close the connection half-way,
something we can't do in sctp.
