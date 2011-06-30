From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] sctp: Enforce maximum retransmissions during shutdown
Date: Thu, 30 Jun 2011 04:49:33 -0400
Message-ID: <20110630084933.GA24074@canuck.infradead.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:57456 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757381Ab1F3Itg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 04:49:36 -0400
Content-Disposition: inline
In-Reply-To: <4E0B4F71.4020108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 12:14:41PM -0400, Vladislav Yasevich wrote:
> Right.  The lack of ABORT from the receive of data is a bug.  I was trying to point out
> that instead of modified the sender of data to send the ABORT, you modify the receiver
> to send the ABORT when it is being closed while having data queued.

Agreed. This makes a good procedure if there is data is on
sk_receive_queue and gets us in line with TCP although I don't see this
in the spec at all :-)

> But we don't even get to sending the SHUTDOWN, so from the wire protocol, we
> do not violated it.  We have bad behavior in that when both sender and receiver
> are dead, the association is hung.

So how do we get out if ...

1) there is nothing queued on sk_receive_queue but the window still
   remains 0 forver?
   
2) the receiver is an older Linux without the above fix or another stack
   that does not ABORT?

I agree that using ABORT on the receiver is the ideal way whenver
possible but we still need to fix this if the receiver does not do so.

What sideeffects are you worried about resulting from my proposal?
