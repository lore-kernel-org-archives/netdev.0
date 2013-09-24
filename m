From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 08:29:24 -0700
Message-ID: <1380036564.3165.76.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
	 <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:50779 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240Ab3IXP30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:29:26 -0400
Received: by mail-pa0-f51.google.com with SMTP id kp14so3825202pab.24
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 08:29:26 -0700 (PDT)
In-Reply-To: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 08:22 -0700, Tom Herbert wrote:

> Assuming skb_rx_hash does symmetric calculation is currently
> incorrect.  For instance, looks like tun.c is trying to implement a
> sort of 'flow director' logic to pair TX queues and RX queues using
> skb_get_rxhash an expecting that the value is calculated
> symmetrically.  If HW is providing RX hash, this is broken and we'll
> never match the flows.  We could either recompute the hash in SW or
> try to match HW hash.

Its not incorrect, its an implementation choice.

Its software in linux, we do not have to care of how its done in
hardware.

This is done to reduce conntracking cost, in case RPS is used on a
router : Same cpu will process frames in both ways.

But conntracking does not 'rely' on rxhash being symmetric, thats an
optimization to have better data locality.
