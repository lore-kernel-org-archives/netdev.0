From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] sctp: Enforce maximum retransmissions during shutdown
Date: Wed, 29 Jun 2011 11:48:14 -0400
Message-ID: <20110629154814.GD10085@canuck.infradead.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:60095 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842Ab1F2PsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 11:48:17 -0400
Content-Disposition: inline
In-Reply-To: <4E0B3DA1.9060200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 10:58:41AM -0400, Vladislav Yasevich wrote:
> But what you are proposing violates the protocol.  Zero-window probes do
> not count against max retransmissions, even when you are in shutdown pending
> state.
> 
> You'll come out of this one of 2 ways:
>   1) receiver wakes up and processes data.  This will allow for graceful termination.
>   2) receiver dies.  Since receive window is full, we have data queued, and this will
>      trigger an ABORT to be sent to the sender.

If by die you mean kill the process then this is exactly what I do to trigger
the issue. I simulatenously kill both processes. Not sure what you mean by
trigger an ABORT but I don't see that happen. I also don't see the rwnd reopen
after the socket is closed on the receiver side but that's a separate issue.

> What you patch is doing is taking a perfectly valid scenario and putting a time limit
> on it in violation of the spec.

We also violate the spec by not doing so. The spec says that the number of
SHUTDOWN retransmissions has to be limited by Max.Retrans which we also
can't enforce because of the above.

The scenario is closed sockets on both sides, endpoints on both sides gone
already and retransmissions + heartbeat requests forever.

Any alternative suggestion how to fix this?
