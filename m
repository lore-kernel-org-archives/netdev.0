From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 3 Jan 2007 21:41:19 -0800
Message-ID: <OF02CC82B6.A4FF1EBC-ON88257259.001EB0D8-88257259.001F3FCF@us.ibm.com>
References: <459C520B.3010406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jarkao2@o2.pl,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:37180 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932281AbXADFlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 00:41:22 -0500
In-Reply-To: <459C520B.3010406@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben,
         If the ip_rcv() and the inetdev_init() are on the same
interface in your stack backtrace, it's a certainty at that point
that the lock value is still 0ed, because none of the initialization
occurs until after it has returned from the function it interrupted
to do the receive.
        It'd have to be out of the register code and doing
ip_mc_init_dev() (after that call) to be a tight race with
lock creation.

                                        +-DLS
