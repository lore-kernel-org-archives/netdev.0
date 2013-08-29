From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tcp: TSO packets automatic sizing
Date: Thu, 29 Aug 2013 16:35:28 -0400 (EDT)
Message-ID: <20130829.163528.638691969523130618.davem@davemloft.net>
References: <1377607592.8828.149.camel@edumazet-glaptop>
	<20130829.155131.1753610025310087003.davem@davemloft.net>
	<1377807977.8277.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	vanj@google.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756080Ab3H2Ufa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:35:30 -0400
In-Reply-To: <1377807977.8277.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Aug 2013 13:26:17 -0700

> Typical bufferbloat at the end of transfert :
> 
> [ 4547.051521] TCP: sk ffff88085825d180 cwnd 327 packets 3 rate 7575936000/srtt 1581
> [ 4547.052722] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 198 sack_rtt 4294967295
> [ 4547.052726] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 198 srtt 1581
> [ 4547.052729] TCP: sk ffff88085825d180 cwnd 327 packets 1 rate 7575936000/srtt 1582
> [ 4547.053315] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 198 sack_rtt 4294967295
> [ 4547.053318] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 198 srtt 1582
> [ 4547.053321] TCP: sk ffff88085825d180 cwnd 327 packets 0 rate 7575936000/srtt 1583
> 
> Maybe we could instead store a value corrected by the sk_pacing_rate
> 
> rate = (big_cwin * mss) / big_srtt
> 
> stored_rtt = rate / (big_cwin * mss)

No objections from me.
