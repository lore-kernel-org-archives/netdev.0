From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] e100: enable transmit time stamping.
Date: Wed, 4 Apr 2012 11:30:11 +0200
Message-ID: <20120404093011.GA4292@netboy.at.omicron.at>
References: <cover.1331400160.git.richardcochran@gmail.com>
 <33c61d135f4fd62e5128466633302414ead0092e.1331400160.git.richardcochran@gmail.com>
 <1333530283.3046.14.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:51056 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105Ab2DDJaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:30:19 -0400
Received: by wibhq7 with SMTP id hq7so74624wib.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:30:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1333530283.3046.14.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 04, 2012 at 02:04:43AM -0700, Jeff Kirsher wrote:
> 
> I had this patch in my queue, but during testing we found some serious
> issues with some adapters.  With every 82559 based adapter Aaron tried
> the system would panic on driver load.  This included at least one
> sampling of D101S and D101M.  Every other e100 chipset Aaron tried
> (82557, 82558, 82550) appeared to work fine.
> 
> So I am dropping this patch as is due to the kernel panics.

Okay, fine. That driver is strangely written, with weird callbacks and
passing function pointers around.

Taking a second look, I think I might have found the problem. The
drivers casts a firmware pointer onto a skb, and my patch then tries
to timestamp the firmware blob.

If I rework this, are you willing to give it another try?

Thanks,
Richard
