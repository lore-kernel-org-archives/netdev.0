From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Wed, 11 Jul 2012 06:53:36 +0200
Message-ID: <1341982416.3265.6764.camel@edumazet-glaptop>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
	 <20120710.210221.559183284956265274.davem@davemloft.net>
	 <1341979678.3265.6660.camel@edumazet-glaptop>
	 <20120710.211304.1112522544390324120.davem@davemloft.net>
	 <1341981861.3265.6740.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47426 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab2GKExk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 00:53:40 -0400
Received: by wgbdr13 with SMTP id dr13so640667wgb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 21:53:39 -0700 (PDT)
In-Reply-To: <1341981861.3265.6740.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 06:44 +0200, Eric Dumazet wrote:

> I dont see where in demux code we have a 64bit access ?

I guess you meant the code in include/net/inet_hashtables.h ?

INET_ADDR_COOKIE() loads the two 32bits into one 64bit register/var
So there is no 64bit alignment in packet header itself.

Then, INET_MATCH does a *(u64 *)&(inet_sk(__sk)->inet_daddr)))

This happens to work because skc_daddr & skc_rcv_saddr are at the
beginning of struct sock_common, and its 8bytes aligned on 64bit arches.
