From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/7] [PPP]: Fix shared/cloned/non-linear skb bugs (was: malformed captured packets)
Date: Fri, 31 Aug 2007 17:06:25 +0800
Message-ID: <20070831090625.GA28175@gondor.apana.org.au>
References: <200708281811.34074.toralf.foerster@gmx.de> <46D521BC.1050300@katalix.com> <200708291822.35128.toralf.foerster@gmx.de> <46D69323.3070503@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3504 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757969AbXHaJHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:07:13 -0400
Content-Disposition: inline
In-Reply-To: <46D69323.3070503@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 09:51:31AM +0000, James Chapman wrote:
>
> The captured PPPoE stream seems to show incorrect data lengths in the
> PPPoE header for some captured PPPoE packets. The kernel's PPPoE
> datapath uses this length to extract the PPP frame and send it through
> to the ppp interface. Since your ppp stream is fine, the actual PPPoE
> header contents must be correct when it is parsed by the kernel PPPoE
> code. It seems more likely that this is a wireshark bug to me.

If he were using the kernel pppoe driver, then this is because
PPP filtering is writing over a cloned skb without copying it.

In fact, there seems to be quite a few bugs of this kind in
the various ppp*.c files.

Please try the following patches to see if they make a
difference.

I've audited ppp_generic.c and pppoe.c.  I'll do pppol2tp
tomorrow.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
