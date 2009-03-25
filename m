From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH] net: Add support for the OpenCores 10/100 Mbps
	Ethernet MAC.
Date: Wed, 25 Mar 2009 15:55:07 +0100
Message-ID: <20090325145507.GC11710@avionic-design.de>
References: <1237889923-32257-1-git-send-email-thierry.reding@avionic-design.de> <20090324120157.GB6859@ports.donpac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:49245 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756454AbZCYOzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 10:55:11 -0400
Content-Disposition: inline
In-Reply-To: <20090324120157.GB6859@ports.donpac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Andrey Panin wrote:
> On 083, 03 24, 2009 at 11:18:43AM +0100, Thierry Reding wrote:
[snip]
> > +static int ethoc_get_multicast_bit(struct dev_mc_list *mc)
> > +{
> > +	u32 crc = 0xffffffff;
> > +	u32 carry;
> > +	int i, j;
> > +
> > +	for (i = 0; i < mc->dmi_addrlen; i++) {
> > +		u8 byte = mc->dmi_addr[i];
> > +
> > +		for (j = 0; j < 8; j++) {
> > +			carry = ((crc & 0x80000000) ? 1 : 0) ^ (byte & 0x1);
> > +			byte >>= 1;
> > +			crc <<= 1;
> > +
> > +			if (carry)
> > +				crc = (crc ^ 0x04c11db6) | carry;
> > +		}
> > +	}
> 
> This looks like yet another crc32 implementation, consider using ether_crc_le()
[snip]

Yes, ether_crc() does the trick. See follow-up patch. Thanks.

Cheers,
Thierry

