From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 22:04:34 -0700
Message-ID: <adad5dmnacd.fsf@cisco.com>
References: <20060605.213250.85688925.davem@davemloft.net>
	<adapshmnbam.fsf@cisco.com> <adalksanb0c.fsf@cisco.com>
	<20060605.215821.69020274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:55626 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932102AbWFFFFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 01:05:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060605.215821.69020274.davem@davemloft.net> (David Miller's message of "Mon, 05 Jun 2006 21:58:21 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> Isn't the IPOIB driver LLTX and therefore the upper layers
    David> are not taking the xmit_lock?

Yeah, but I think that should be OK.  If I'm remembering the intention
of the code correctly, the reason xmit_lock is being taken there is
just to protect dev->mc_list -- and this is needed because ipoib has
to defer handling set_multicast_list to process context.  Am I right
in thinking that dev->xmit_lock still serializes mc_list operations,
even for LLTX drivers?

 - R.
