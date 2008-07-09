From: David Miller <davem@davemloft.net>
Subject: Re: bnx2_poll panicking kernel
Date: Wed, 09 Jul 2008 16:46:59 -0700 (PDT)
Message-ID: <20080709.164659.157912631.davem@davemloft.net>
References: <4863DA40.9050508@broadcom.com>
	<20080709164619.GA26098@orion.carnet.hr>
	<1215622625.5532.43.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joy@debian.org, billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751851AbYGIXq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 19:46:59 -0400
In-Reply-To: <1215622625.5532.43.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 09 Jul 2008 09:57:05 -0700

> That was just a debug patch.  The proper fix needs to go into
> tso_fragment() as David outlined earlier.

Actually I went investigating this and all the code paths check for
skb_cloned() and if true they make a copy of the data area (and thus
the skb_shared_info()) and this should ensure that the driver doesn't
see changing nr_frags values.

So it has to be something else.
