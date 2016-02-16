From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] af_unix: Guard against other == sk in
 unix_dgram_sendmsg
Date: Tue, 16 Feb 2016 12:54:58 -0500 (EST)
Message-ID: <20160216.125458.1817148468081256050.davem@davemloft.net>
References: <87r3gjjgbu.fsf@doppelsaurus.mobileactivedefense.com>
	<87egcjcd5j.fsf@doppelsaurus.mobileactivedefense.com>
	<87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, pmhahn@pmhahn.de, hannes@stressinduktion.org,
	sasha.levin@oracle.com, linux-kernel@vger.kernel.org,
	kseeger@samba.org, jbaron@akamai.com, gregkh@linuxfoundation.org,
	requate@univention.de, gohmann@univention.de,
	netdev@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Thu, 11 Feb 2016 19:37:27 +0000

> The unix_dgram_sendmsg routine use the following test
> 
> if (unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {
> 
> to determine if sk and other are in an n:1 association (either
> established via connect or by using sendto to send messages to an
> unrelated socket identified by address). This isn't correct as the
> specified address could have been bound to the sending socket itself or
> because this socket could have been connected to itself by the time of
> the unix_peer_get but disconnected before the unix_state_lock(other). In
> both cases, the if-block would be entered despite other == sk which
> might either block the sender unintentionally or lead to trying to unlock
> the same spin lock twice for a non-blocking send. Add a other != sk
> check to guard against this.
> 
> Fixes: 7d267278a9ec ("unix: avoid use-after-free in ep_remove_wait_queue")
> Reported-By: Philipp Hahn <pmhahn@pmhahn.de>
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Also applied and queued up for -stable, thanks.
