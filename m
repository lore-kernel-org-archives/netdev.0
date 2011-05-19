From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 21:24:42 +0200
Message-ID: <4DD56E7A.3010901@neli.hopto.org>
References: <4DD36803.1020001@neli.hopto.org>	 <20110518.023725.441358922110721042.davem@davemloft.net>	 <4DD36E54.9040706@neli.hopto.org>	 <20110518.181427.1228926976939865196.davem@davemloft.net> <1305819120.3271.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-01.edutel.nl ([88.159.1.175]:42088 "EHLO
	edu-smtp-01.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934236Ab1ESTZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:25:17 -0400
In-Reply-To: <1305819120.3271.3.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams wrote:
> Shouldn't the code still wait at *least* one second?  Not all drivers
> support carrier detect, and those that don't set the carrier always-on.
> Thus older devices that used to have 1s to get carrier in line (even if
> they don't report it) now have only 10ms.

Btw, it does not matter much, there are 2 cases:
1) DHCP: dhcp will retry every few seconds, so if link is not up, then a
later try will succeed
2) Static IP: an ARP request is performed every second, so the second
request will be answered instead of the first.

Even if link is "fake up" by driver and not actually up after 10 msecs,
things will continue to work (eventually), after a second, just like now.

Micha
