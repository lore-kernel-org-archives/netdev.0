From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Yet another bridge netfilter crash
Date: Fri, 23 Jul 2010 21:42:08 +0800
Message-ID: <20100723134208.GA6655@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49110 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab0GWNmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 09:42:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

I was cced on the following bug:

https://bugzilla.redhat.com/show_bug.cgi?id=617268

>From what I've seen in the crash dump, this would appear to be
yet another manifestation of the evil relationship between the
bridge and IPv4 through netfilter.

In particular, bridge netfilter invokes IPv4's PRE_ROUTING rules,
one of which assembles packets for connection tracking.

Unfortunately, the same cache is used for reassembling bridge
packets and non-bridge packets.

Now we already knew about this and its potential security effects.
However, what we didn't know is that this can also cause a packet
to appear in the bridge pre_routing code with nf_bridge set to
NULL when it must not be NULL.

This happens if the non-bridge fragment appeared first.

So now is the time to fix this properly by giving the bridge its
own separate conntrack namespace/zone.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
