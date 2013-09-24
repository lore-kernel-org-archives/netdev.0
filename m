From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: net_secret should not depend on TCP
Date: Tue, 24 Sep 2013 08:46:27 -0700
Message-ID: <1380037587.3165.82.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924054532.GA24446@order.stressinduktion.org>
	 <1380028797.3165.65.camel@edumazet-glaptop>
	 <20130924151333.GA1527@order.stressinduktion.org>
	 <1380036147.3165.72.camel@edumazet-glaptop>
	 <20130924152858.GB1527@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:51024 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390Ab3IXPqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:46:33 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so3858148pab.11
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 08:46:33 -0700 (PDT)
In-Reply-To: <20130924152858.GB1527@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 17:28 +0200, Hannes Frederic Sowa wrote:

> But couldn't it be that get_random_bytes always returns 0 and we won't make
> any progress here. Does the reseed happen from irq context or from softirqs? I
> always thought it would be from a softirq (which could be blocked).

Really if get_random_bytes() could return 0 forever I think we would
have a big problem with its implementation and documentation :

/*
 * This function is the exported kernel interface.  It returns some
 * number of good random numbers, suitable for key generation, seeding
 * TCP sequence numbers, etc.  It does not use the hw random number
 * generator, if available; use get_random_bytes_arch() for that.
 */
void get_random_bytes(void *buf, int nbytes)
{
        extract_entropy(&nonblocking_pool, buf, nbytes, 0, 0);
}
EXPORT_SYMBOL(get_random_bytes);
