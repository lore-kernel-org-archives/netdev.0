From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC] netem:  de-GSO packets before enqueing
Date: Sat, 14 Jan 2012 17:06:46 +0100
Message-ID: <20120114160646.GB2966@hell>
References: <1326400930.2740.10.camel@bwh-desktop>
 <20120112220328.GA10813@gondor.apana.org.au>
 <20120112165720.4545c670@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57195 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753678Ab2ANQGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 11:06:48 -0500
Content-Disposition: inline
In-Reply-To: <20120112165720.4545c670@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger | 2012-01-12 16:57:20 [-0800]:

>Probably something like this is needed (untested).
>
>This issue was discovered when looking at the skb_checksum path for the
>netem corruption operation, but it is a general problem.
>Network emulation operations like corruption and drop want to operate
>on a per-packet (not per-segment) basis. This patch does GSO in software
>if necessary to break up packets.  Code is similar to logic in xfrm_output.
>
>Although it appears that the operation is not work conserving, it is okay
>because the higher level qdisc operations account for packets by incrementing
>by gso_size.

Thanks Stephen! Corruption is currently unusable if GSO is enabled. We disable
GSO/TSO on all our test machines therefore.

I have a larger set of patches for the corruption option for this merge
window. We will now test your patch (and the hopefully following qdisc len
updated patch).

Hagen
