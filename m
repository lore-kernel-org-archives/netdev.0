From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 04 Aug 2009 13:05:51 -0400
Message-ID: <4A786A6F.10902@librato.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>	<1248295301-30930-6-git-send-email-danms@us.ibm.com>	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>	<4A6F6B19.9010508@librato.com> <878wi6yxui.fsf@caffeine.danplanet.com>	<4A77F0EF.9090602@librato.com> <87ws5jlidl.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp241.iad.emailsrvr.com ([207.97.245.241]:36618 "EHLO
	smtp241.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932882AbZHDRFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 13:05:54 -0400
In-Reply-To: <87ws5jlidl.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> Does this mean that a situation of A->B and B->C is valid only as
> OL> long as A->B is done first, otherwise A->B will fail because B
> OL> will already be connected to C ?
> 
> Correct.

Hmm.. this also means that if A->C already, then an attempt to also
do B->C will fail :(

> 
> OL> Then, the other problem is to restore correctly you need to mimic
> OL> the behavior of sendto() because of the way the skb references the
> OL> original socket for the write-buf accounting :(
> 
> OL> In turn, this means that during checkpoint you need to record the
> OL> _origin_ of each buffer in the queue of afunix dgram sockets :((
> 
> Or return EBUSY when there are skb's that are outstanding from before
> the re-connect, right?

Hmm.. I think that when you reconnect a dgram socket, it discards all
unread pending data previous received, whether through connection or
via sendto().

What I meant is that restore (and therefore checkpoint) need to know
how to handle skb's sent with sendto() but without proper connection,
where the target socket is still unconnected.

I'm ok with declaring this case unsupported for now and put it in the
'todo' list, and meanwhile work towards getting the current afunix
patches into the cr-dev tree. (As long as it doesn't it will be buried
there forever...)

Oren.

