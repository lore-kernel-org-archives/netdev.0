From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH V2] net: add accounting for socket backlog
Date: Mon, 01 Mar 2010 10:08:48 +0800
Message-ID: <1267409328.23196.37.camel@debian>
References: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
	 <20100226.040536.247057194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2380 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351Ab0CACHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 21:07:16 -0500
In-Reply-To: <20100226.040536.247057194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-26 at 20:05 +0800, David Miller wrote:
> So remind me why TCP, or any other non-UDP protocol, won't
> intrinsically have this problem too?

If TCP ACKs are not received, the (closed) remote window prevents the
TCP sender to send more frames.

> It seems pretty trivial to do with any protocol, especially remotely,
> with a packet generator.  The code in TCP, for example, which queues
> to the backlog, doesn't care about sequence numbers or anything like
> that.
> 
> So you could spray a machine with the same TCP frame over and over
> again, as fast as possible, as long as it matches the socket identity.
> 
> And in this way fill up the backlog endlessly and OOM the system. 

Yeah, I only considered about the normal case, that is the TCP frames
are built and managed in the kernel. If a user does frame generation
himself, yes, the same problem could happen potentially for all
protocols using backlog.

Thanks,
-yi

