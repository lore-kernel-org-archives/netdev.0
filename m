From: Patrick McManus <mcmanus@ducksong.com>
Subject: RE: 2.6.27 problem with shaping using netem/ifb (regression?) [TSO]
Date: Thu, 02 Oct 2008 11:49:20 -0400
Message-ID: <1222962561.7392.7.camel@tng>
References: <1222902286.6395.22.camel@tng>
	 <36D9DB17C6DE9E40B059440DB8D95F52064FB007@orsmsx418.amr.corp.intel.com>
	 <1222912542.6395.30.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	herbert@gondor.apana.org.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:40573 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbYJBPt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 11:49:26 -0400
In-Reply-To: <1222912542.6395.30.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing a little further, the key element is tso on loopback. 

It is off by default for 23->26, and on by default in 27. My script is
always broken whenever I turn tso on for lo regardless of version.

So maybe just a lo/tso interaction problem not a regression.

The change that turned it on by default went into 27-rc4:

commit f22f8567cb0a530d8958d177e0f268783bd0d894
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Aug 15 14:52:08 2008 -0700

    loopback: Enable TSO

    This patch enables TSO since the loopback device is naturally
    capable of handling packets of any size.  This also means that
    we won't enable GSO on lo which is good until GSO is fixed to
    preserve netfilter state as netfilter treats loopback packets
    in a special way.

    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>


