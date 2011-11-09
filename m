From: Joe Perches <joe@perches.com>
Subject: Re: dst->obsolete has become pointless
Date: Wed, 09 Nov 2011 15:56:09 -0800
Message-ID: <1320882969.6923.29.camel@Joe-Laptop>
References: <20111108.122020.1080743546477280623.davem@davemloft.net>
	 <20111108.135901.1506278599930259562.davem@davemloft.net>
	 <1320842948.6923.3.camel@Joe-Laptop>
	 <20111109.142044.1307358041881082836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60336 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752566Ab1KIX4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 18:56:10 -0500
In-Reply-To: <20111109.142044.1307358041881082836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-09 at 14:20 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 09 Nov 2011 04:49:08 -0800
> 
> > On Tue, 2011-11-08 at 13:59 -0500, David Miller wrote:
> >> net: Kill pointless and misleading checks on dst->obsolete.
> > []
> >> Therefore rename it to dst->freed, and make it take on only the values
> >> "0" and "1".
> >> diff --git a/include/net/dst.h b/include/net/dst.h
> > []
> >> @@ -55,7 +55,7 @@ struct dst_entry {
> >>  #define DST_NOCOUNT		0x0020
> >>  
> >>  	short			error;
> >> -	short			obsolete;
> >> +	unsigned short		freed;
> > 
> > perhaps
> > 	bool freed;
> > 	bool __pad3;
> > just to mark the available space a bit more obviously.
> 
> Hmmm, what is a bool's defined type anyways?  It is a char on every
> architecture and ABI?

As far as I know, other than being large enough to
store a 1 and 0, it's implementation defined.

Just like an unsigned short.

I _believe_ gcc uses unsigned char width for
_Bool in all normal cases though.
