From: Joe Perches <joe@perches.com>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 04:15:16 -0700
Message-ID: <1349867716.2386.35.camel@joe-AO722>
References: <20121010093816.GA3669@elgon.mountain>
	 <1349864358.2386.27.camel@joe-AO722>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B702D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48468 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755896Ab2JJLPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 07:15:16 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B702D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 11:42 +0100, David Laight wrote:
> > -		unsigned long protos[8] = {0,};
> > +		DECLARE_BITMAP(protos, BITS_PER_LONG * 8) = { 0, };
> ...
> > -		if ((r = set_arg(argp, protos, 8 * sizeof(long))))
> > +		if ((r = set_arg(argp, protos, sizeof(protos))))
> 
> That change makes a big assumption about the implementation
> of DECLARE_BITMAP().
> Unless it is guaranteed to be implemented as 'unsigned long[]'
> then you've changed what the code might do.

Possible, but it's hard to imagine it changing.

The = { 0, } should probably be bitmap_zero
