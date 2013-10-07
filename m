From: David Miller <davem@davemloft.net>
Subject: Re: bug in passing file descriptors
Date: Mon, 07 Oct 2013 15:12:33 -0400 (EDT)
Message-ID: <20131007.151233.2237348893254566536.davem@davemloft.net>
References: <5252FD2B.5040800@nec-labs.com>
	<CALCETrXmmW-nRTr4-yWJnNr2GWW37KW-7B1m=kSRnmYjhMTajA@mail.gmail.com>
	<5253061A.7060701@nec-labs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, netdev@vger.kernel.org,
	mtk.manpages@gmail.com, ebiederm@xmission.com
To: sar@nec-labs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573Ab3JGTMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:12:35 -0400
In-Reply-To: <5253061A.7060701@nec-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Rago <sar@nec-labs.com>
Date: Mon, 7 Oct 2013 15:06:02 -0400

> Maybe.  So a client expecting to receive x bytes of control
> information should make sure their buffer is at least CMSG_SPACE(x)
> bytes long instead of CMSG_LEN(x) bytes long, because you feel
> compelled to copy the final padding from kernel space to user space?
> Seems wrong to me.  IMHO, the final padding should only come into play
> when calculating where the next header should begin.

Yes, all control messages must be aligned to, and be of a length of a
multiple of, "sizeof(long)".

This is the only correct way to program control messages.
