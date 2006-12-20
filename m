From: David Miller <davem@davemloft.net>
Subject: Re: Bug 7596 - Potential performance bottleneck for Linxu TCP
Date: Tue, 19 Dec 2006 21:15:51 -0800 (PST)
Message-ID: <20061219.211551.112620476.davem@davemloft.net>
References: <E1Gwokt-00050T-00@gondolin.me.apana.org.au>
	<20061219.185525.41636407.davem@davemloft.net>
	<20061219211124.061b5c2d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mingo@elte.hu, akpm@osdl.org,
	wenji@fnal.gov, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932949AbWLTFQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 00:16:20 -0500
To: shemminger@osdl.org
In-Reply-To: <20061219211124.061b5c2d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 19 Dec 2006 21:11:24 -0800

> It was the realtime/normal comments that piqued my interest.
> Perhaps we should either tweak process priority or remove
> the comments.

I mentioned that to Linus once and he said the entire
idea was bogus.

With the recent tcp_recvmsg() preemption issue thread,
I agree with his sentiments even more than I did previously.

What needs to happen is to liberate the locking so that
input packet processing can occur in parallel with
tcp_recvmsg(), instead of doing this bogus backlog thing
which can wedge TCP ACK processing for an entire quantum
if we take a kernel preemption while the process has the
socket lock held.
