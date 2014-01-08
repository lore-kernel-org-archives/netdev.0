From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/5] tcp: metrics: Add source-address to
 tcp-metrics
Date: Wed, 08 Jan 2014 09:55:51 -0800
Message-ID: <1389203751.26646.100.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1389193559-16756-3-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:35174 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbaAHRzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 12:55:44 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so1886470pbc.20
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 09:55:43 -0800 (PST)
In-Reply-To: <1389193559-16756-3-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-08 at 16:05 +0100, Christoph Paasch wrote:
> We add the source-address to the tcp-metrics, so that different metrics
> will be used per source/destination-pair. We use the destination-hash to
> store the metric inside the hash-table. That way, deleting and dumping
> via "ip tcp_metrics" is easy.

Note that this has the following problem :

Some applications use a set of source IP addresses to overcome the 64K
port limitation.

tcp_metrics uses a hard-coded TCP_METRICS_RECLAIM_DEPTH value of 5,
meaning that cache wont be able to store more than 5 source IP addresses
(reaching one particular remote IP).
