From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH RFC 5/6] net/faraday: Enable NCSI interface
Date: Tue, 10 Nov 2015 07:28:24 +1100
Message-ID: <1447100904.31884.26.camel@kernel.crashing.org>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1447027806-4744-6-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1447029127.8727.29.camel@kernel.crashing.org>
	 <20151109073032.GA10235@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:42098 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbbKIU2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2015 15:28:34 -0500
In-Reply-To: <20151109073032.GA10235@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-09 at 18:30 +1100, Gavin Shan wrote:
> 
> Yeah, It's something that I hilighed in the cover letter. I was
> thinking we might need a better way to enable Tx/Rx before the
> interrupt is up, but couldn't figure out one way. So I need some
> advice here.

No, that's not right. For Tx/Rx to work the interface must be opened,
there is simply no way around that and that's perfectly fine. The
situation with an MDIO PHY is the same, most drivers can't talk to
their PHY until the interface has been opened because the chip is
basically powered down otherwise.

So we require the interface to be opened to talk, so far so good,
the NC-SI stack doesn't even need to open it itself, it's acceptable
to require userspace to do it. IE. Userspace will chose what interface
to use, open it (for DHCP etc... or whatever other reason) and *that*
will then trigger the NC-SI negociation.

Cheers,
Ben.
