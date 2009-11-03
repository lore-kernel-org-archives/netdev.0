From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] usbnet: Do not implement ethtool get_link() if link state is unknown
Date: Tue, 3 Nov 2009 02:41:27 -0700
Message-ID: <200911030141.27905.david-b@pacbell.net>
References: <1257218818.3136.440.camel@localhost> <200911022201.30950.david-b@pacbell.net> <20091103.010129.100672838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, greg@kroah.com, jacmet@sunsite.dk,
	steve.glendinning@smsc.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.sbc.mail.gq1.yahoo.com ([67.195.15.61]:23828 "HELO
	smtp102.sbc.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755580AbZKCJsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:48:04 -0500
In-Reply-To: <20091103.010129.100672838.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 November 2009, David Miller wrote:
> > Having two tables for this is needlessly ugly.
> 
> Yes, it's really cruddy how the USB network driver tries to share
> so much state amongst such very different devices :-)

That framework just grew ... started out as one driver,
nearly ten years back (yow!!), then generalized.  Folk
seemed to appreciate not reinventing some stuff.  ;)

If it had started out with this many devices, it might have
looked more like a library.  Sharing code implies sharing
at least some state representations; the balance could might
be worth shifting by now.


> All kidding aside, I think the alternative is for the USB network
> driver to call ethtool_op_get_link() if it cannot determine the
> link state in hardware.

There's usbnet_get_link() which does just that.  But
there may be some ancient debris confusing things.
