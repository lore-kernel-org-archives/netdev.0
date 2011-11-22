From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 18:41:32 +0300
Message-ID: <20111122154132.GA25127@p183.telecom.by>
References: <1321974652.2474.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AED9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65079 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755349Ab1KVPli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:41:38 -0500
Received: by bke11 with SMTP id 11so341577bke.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 07:41:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AED9@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2011 at 03:15:25PM -0000, David Laight wrote:
>  
> > Please use :
> > 
> > +static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
> > +{
> > +       /* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> > +       if (prefixlen == 0)
> > +               return true;
> > +       return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> > +}
> 
> I'm not sure I'd agree about using 'u8'.
> It may well cause an unnecessary mask with 0xff.

It's u8 in all other places.
