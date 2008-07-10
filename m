From: David Miller <davem@davemloft.net>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 10 Jul 2008 14:00:16 -0700 (PDT)
Message-ID: <20080710.140016.171249048.davem@davemloft.net>
References: <1215622625.5532.43.camel@dell>
	<20080709.164659.157912631.davem@davemloft.net>
	<1215723617.6901.3.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joy@debian.org, billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754222AbYGJVAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 17:00:16 -0400
In-Reply-To: <1215723617.6901.3.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Jul 2008 14:00:17 -0700

> On Wed, 2008-07-09 at 16:46 -0700, David Miller wrote:
> > Actually I went investigating this and all the code paths check for
> > skb_cloned() and if true they make a copy of the data area (and thus
> > the skb_shared_info()) and this should ensure that the driver doesn't
> > see changing nr_frags values.
> 
> Since Josip can readily reproduce this problem, let's confirm if the SKB
> is split while it is cloned.  Please try this debug patch:

Another good place to check would be __pskb_trim_head() in
net/ipv4/tcp_output.c but the skb_cloned() check in one of that
function's only callers (tcp_trim_head) is rather explicit :-)
