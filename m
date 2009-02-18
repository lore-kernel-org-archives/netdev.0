From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 2/3] [kernel] Add support for RX packet classification
 in a network device
Date: Tue, 17 Feb 2009 22:07:05 -0800
Message-ID: <1234937225.31073.187.camel@brick>
References: <49999FA3.7040300@Sun.COM>
	 <20090217.202838.66382200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Santwona.Behera@Sun.COM, netdev@vger.kernel.org, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net, Matheos.Worku@Sun.COM,
	Mehdi.Bonyadi@Sun.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:19722 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbZBRGHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 01:07:09 -0500
Received: by rv-out-0506.google.com with SMTP id g37so2381606rvb.1
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 22:07:07 -0800 (PST)
In-Reply-To: <20090217.202838.66382200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-02-17 at 20:28 -0800, David Miller wrote:
> From: Santwona.Behera@Sun.COM
> Date: Mon, 16 Feb 2009 09:17:23 -0800
> 
> > -struct ethtool_rxnfc {
> > -	__u32		cmd;
> > +/* The following structures are for supporting RX network flow
> > + * classification configuration. Note, all multibyte fields, e.g.,
> > + * ip4src, ip4dst, psrc, pdst, spi, etc. are expected to be in network
> > + * byte order.
> > + */
> > +struct ethtool_tcpip4_spec {
> > +	__u32	ip4src;
> > +	__u32	ip4dst;
> > +	__u16	psrc;
> > +	__u16	pdst;
> > +	__u8    tos;
> > +};
> 
> We have specific types for this, "__be32" et al.
> 
> Please use them.
> 
> And once you do that properly, checking the code with sparse via "make
> C=1" will warn for you if these data items are not accessed as
> big-endian items.

make C=1 CF=-D__CHECK_ENDIAN__

The endian checks aren't on yet by default due to the noise level, but
after the work over the past few kernel releases it may be getting
close.

I'll look again and see what it looks like for the next devel cycle.

Harvey


