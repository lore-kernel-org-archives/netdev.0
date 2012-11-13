From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: tcp_replace_ts_recent() should not be called
 from tcp_validate_incoming()
Date: Tue, 13 Nov 2012 14:35:44 -0500 (EST)
Message-ID: <20121113.143544.503592471078426014.davem@davemloft.net>
References: <87k3tp6783.fsf@silenus.orebokech.com>
	<1352813332.6185.29.camel@edumazet-glaptop>
	<1352821038.6185.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romain@orebokech.com, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com, nanditad@google.com, hkchu@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab2KMTfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:35:45 -0500
In-Reply-To: <1352821038.6185.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Nov 2012 07:37:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We added support for RFC 5961 in latest kernels but TCP fails
> to perform exhaustive check of ACK sequence.
> 
> We can update our view of peer tsval from a frame that is
> later discarded by tcp_ack()
> 
> This makes timestamps enabled sessions vulnerable to injection of
> a high tsval : peers start an ACK storm, since the victim
> sends a dupack each time it receives an ACK from the other peer.
> 
> As tcp_validate_incoming() is called before tcp_ack(), we should
> not peform tcp_replace_ts_recent() from it, and let callers do it
> at the right time.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks a lot.
