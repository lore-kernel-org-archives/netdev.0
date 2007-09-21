From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH RESEND] 2.6.22.6 networking [ipv4]: fix wrong destination when
 reply packetes
Date: Thu, 20 Sep 2007 21:35:09 -0700
Message-ID: <OFC759A0A2.B923AD69-ON8825735D.0017012F-8825735D.00191D21@us.ibm.com>
References: <20070921022335.GA2849@router.lepton.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: lkm <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: lepton <ytht.net@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:41643 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbXIUEfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 00:35:14 -0400
In-Reply-To: <20070921022335.GA2849@router.lepton.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not sure why it's using rt_src here, but there are relevant cases that
your description doesn't cover. For example, what happens if  the source
is not set in the original packet?  Does NAT affect this?

You quote RFC text for ICMP echo and the case where the receiving machine
is the final destination, but you're modifying code that is used for all 
ICMP
types and used for ICMP errors generated when acting as an intermediate
router.

In ordinary cases, and certainly with ICMP echo when the source is set in
the original packet and no rewriting is going on (and the address is not 
spoofed),
using the original source as the destination is fine. But have you tested 
or
considered the other cases?

                                                +-DLS

