From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 17:59:40 +0300
Message-ID: <20111122145940.GA24909@p183.telecom.by>
References: <20111122144334.GA22824@p183.telecom.by>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AED7@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58527 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab1KVO7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 09:59:45 -0500
Received: by mail-bw0-f46.google.com with SMTP id 11so296854bke.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 06:59:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AED7@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2011 at 02:50:59PM -0000, David Laight wrote:
>  
> > +static inline int addr4_match(const __be32 a1, const __be32 
> > a2, const u8 prefixlen)
> > +{
> > +	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> > +	if (prefixlen == 0) {
> > +		/* Matching constants result in smaller assembly. */
> > +		return 0xFFFFFFFFu;
> > +	}
> > +	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> > +}
> > +
> 
> It would probably be clearer to 'return 1' when prefixlen is zero.

"return 1" results in bigger code.
This function used only in boolean context, so exact return value doesn't matter.

> If this is a common path, might be worth caching
>     htonl(0xFFFFFFFFu << (32 - prefixlen))
> in the enclosing structure.

This means one more branch, which wouldn't be a win compared
to current code.
