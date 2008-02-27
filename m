From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] [resend]The kernel gets no IP from some DHCP servers,
 2.6.24
Date: Wed, 27 Feb 2008 08:38:19 -0800
Message-ID: <20080227083819.70ddb374@extreme>
References: <83116F0A4FF67A4F97BA0B6E408C48E301C5CDEF@zuerich.BC-Int.NET>
	<47C55BBF.7080501@trash.net>
	<83116F0A4FF67A4F97BA0B6E408C48E301C5CE08@zuerich.BC-Int.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <ebiederman@lnxi.com>
To: "Wappler Marcel" <Marcel.Wappler@bridgeco.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:58982 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754576AbYB0QiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 11:38:24 -0500
In-Reply-To: <83116F0A4FF67A4F97BA0B6E408C48E301C5CE08@zuerich.BC-Int.NET>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Feb 2008 14:11:55 +0100
"Wappler Marcel" <Marcel.Wappler@bridgeco.net> wrote:

> -----Original Message-----
> >>  #include <linux/types.h>
> >> @@ -103,6 +107,7 @@
> >>  					   - '3' from resolv.h */
> >>  
> >>  #define NONE __constant_htonl(INADDR_NONE)
> >> +#define ZERO __constant_htonl(((unsigned long int) 0x00000000))
> >This should probably use INADDR_ANY.
> My first try went in this direction. But at a second look I thought
> that the names ANY (255.255.255.255) and NONE (0.0.0.0) are indirect
> leading to confusion. The interpretation of the zero addresses in
> the DHCPDISCOVER packet is in the kind of 'no address' and not of
> 'any addressee'. So the meaning and usage of INADDR_ANY and ZERO
> may be totally different in this file.
> In my opinion it is necessary to distinguish between INADDR_ANY
> and the ZERO address which ist requested to be in the DHCPDISCOVER
> packet.
> 

Just delete the lines and the address will be zero because of
earlier memset().
