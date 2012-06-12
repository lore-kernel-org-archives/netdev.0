From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 net-next] ipv4: Add interface option to enable routing
 of 127.0.0.0/8
Date: Tue, 12 Jun 2012 07:31:15 -0400
Message-ID: <20120612113115.GI28598@canuck.infradead.org>
References: <20120608101859.GH32152@canuck.infradead.org>
 <20120611.165740.419299184892679723.davem@davemloft.net>
 <20120612104401.GH28598@canuck.infradead.org>
 <20120612111444.GA15984@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:42909 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab2FLLbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 07:31:18 -0400
Content-Disposition: inline
In-Reply-To: <20120612111444.GA15984@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 12, 2012 at 07:14:44AM -0400, Neil Horman wrote:
> Just out of curiosity, would it be more efficient to implement this by
> optionally adding a prohibit route to the local table for 127.0.0.0/8 to every
> interface that was brought up, based on weather or not that interfaces
> route_localnet bool was true or not?  It would save the additional checks in the
> routing path I think.  Not sure how much a savings that is, but I thought I
> would ask.

It's not that simple because we also use the local table for source
address selection and local address verification. So we would have to
exclude/include such routes conditionally based on some route lookup
purpose indicator. Such a prohibit route would have to be valid only
in the output context.
