From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: add mac_pton() for parsing MAC address
Date: Wed, 4 May 2011 20:39:59 +0300
Message-ID: <20110504173959.GA16221@p183>
References: <20110504061551.GA12297@p183>
 <20110504081225.267a0833@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38685 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463Ab1EDRkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:40:04 -0400
Received: by fxm17 with SMTP id 17so1001729fxm.19
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 10:40:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110504081225.267a0833@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 04, 2011 at 08:12:25AM -0700, Stephen Hemminger wrote:
> On Wed, 4 May 2011 09:15:51 +0300
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > +int mac_pton(const char *s, u8 *mac)
> > +{
> > +	int i;
> > +
> > +	/* XX:XX:XX:XX:XX:XX */
> > +	if (strlen(s) < 3 * ETH_ALEN - 1)
> > +		return 0;
> > +
> > +	/* Don't half dirty result. */
> Shouldn't this be "Don't allow dirty result."?

Maybe.
It means "only dirty result, if everything is OK." like inet_pton(3).

> > +	for (i = 0; i < ETH_ALEN; i++) {
> > +		if (!strchr("0123456789abcdefABCDEF", s[i * 3]))
> > +			return 0;
> > +		if (!strchr("0123456789abcdefABCDEF", s[i * 3 + 1]))
> > +			return 0;
> 
> 		if (!isxdigit(s[i*3]) || !isxdigit(s[i*3+1]))
> 			return 0;
> 
> > +		if (i != ETH_ALEN - 1 && s[i * 3 + 2] != ':')
> > +			return 0;
> > +	}
> > +	for (i = 0; i < ETH_ALEN; i++) {
> > +		mac[i] = (hex_to_bin(s[i * 3]) << 4) | hex_to_bin(s[i * 3 + 1]);
> 		hex2bin(&mac[i], &s[i*3], 1);
> > +	}
> > +	return 1;
> > +}
> > +EXPORT_SYMBOL(mac_pton);
> 
> Also don't need two loops, okay to parse partial result.

You need two loops if code is written as sent.
Otherwise, caller need temporary buffer to not corrupt possibly important
previous MAC value.
