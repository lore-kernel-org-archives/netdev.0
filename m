From: David Miller <davem@davemloft.net>
Subject: Re: ICMP redirect issue
Date: Wed, 28 Sep 2011 14:06:32 -0400 (EDT)
Message-ID: <20110928.140632.726302773135946390.davem@davemloft.net>
References: <20110927162120.30394030@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab1I1SHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 14:07:04 -0400
In-Reply-To: <20110927162120.30394030@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Tue, 27 Sep 2011 16:21:20 -0300

> The issue is about the gateway being a LVS, so the servers behind use
> the IP alias address as the default gateway.  However, when the gateway
> sends an ICMP redirect, it comes from the primary IP address which is
> ignored on older kernels because of the old_gw check:
> 
> -                               if (rth->rt_dst != daddr ||
> -                                   rth->rt_src != saddr ||
> -                                   rth->dst.error ||
> -                                   rth->rt_gateway != old_gw ||
> -                                   rth->dst.dev != dev)
> -                                       break;
> 
> 
> Well, the consequence is that the issue doesn't happen in newer kernels
> because it happily accepts the ICMP redirect.
> 
> The admin can still control using shared_media and secure_redirects if
> the host should accept only the ICMP redirects for gateways listed in
> default gateway list or not.

Unfortunately, shared_media is on by default which means the default
secure_redirects setting of '1' is ignored.

This means that redirects can be spoofed in the default configuration,
but with the above check they would not be spoofable.

I suspect that, because of this, we'll need to add the check back.  Or
do something similar.

We can't "fix" this by turning shared_media off by default because that
changes behavior on input route processing wrt. how we decide whether
to emit a redirect or not.
