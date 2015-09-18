From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp_cubic: do not set epoch_start in the future
Date: Thu, 17 Sep 2015 22:35:35 -0700 (PDT)
Message-ID: <20150917.223535.157337200633800999.davem@davemloft.net>
References: <1442504280.16225.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	jri@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbIRFfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 01:35:36 -0400
In-Reply-To: <1442504280.16225.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Sep 2015 08:38:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Tracking idle time in bictcp_cwnd_event() is imprecise, as epoch_start
> is normally set at ACK processing time, not at send time.
> 
> Doing a proper fix would need to add an additional state variable,
> and does not seem worth the trouble, given CUBIC bug has been there
> forever before Jana noticed it.
> 
> Let's simply not set epoch_start in the future, otherwise
> bictcp_update() could overflow and CUBIC would again
> grow cwnd too fast.
> 
> This was detected thanks to a packetdrill test Neal wrote that was flaky
> before applying this fix.
> 
> Fixes: 30927520dbae ("tcp_cubic: better follow cubic curve after idle period")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Cc: Jana Iyengar <jri@google.com>

Applied, thanks.
