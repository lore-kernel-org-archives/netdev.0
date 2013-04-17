From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next 1/4] bnx2x: refactor nvram read procedure
Date: Wed, 17 Apr 2013 20:19:58 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20C04CDA@SJEXCHMB06.corp.ad.broadcom.com>
References: <1365843411-27103-1-git-send-email-dmitry@broadcom.com>
 <1365843411-27103-2-git-send-email-dmitry@broadcom.com>
 <20130413110916.GA20436@electric-eye.fr.zoreil.com>
 <504C9EFCA2D0054393414C9CB605C37F20C03E5D@SJEXCHMB06.corp.ad.broadcom.com>
 <20130415233151.GA30171@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3964 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935448Ab3DQUVd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 16:21:33 -0400
In-Reply-To: <20130415233151.GA30171@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Tuesday, April 16, 2013 2:32 AM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Eilon Greenstein
> Subject: Re: [PATCH net-next 1/4] bnx2x: refactor nvram read procedure
> 
> Dmitry Kravkov <dmitry@broadcom.com> :
> [...]
> > > You memcpy a u32 to an array of bytes instead of copying it byte after
> > > byte with proper shift operators and now you are paving the way for more
> > > endianess headaches. I'd rather avoid the memcpy when readying data for
> > > ethtool in the first place.
> > In case of _be data I don't see any issue with copying _be32 it into byte array.
> 
> The modified code (bnx2x_nvram_read) will not be copying __be32 but u32.
> It issmuggling _be data behind neutral u32 and using casting when the
> kernel has provided cpu_to_{le / be} helpers for years. Think of type
> checking as kind of messed up as soon as u32 *ret_val contains a _le or
> _be data depending on the value of bool to_be.
> 
> I don't want to worry about the endianness of a u32. If it's a u32 (u16,
> s32, whatever), I only want to think of bytes in it through '>>' or '<<'
> operators. No need to remember the semantic of the last bnx2x_nvram_read_dword
> parameter, if it's internal, external, nor assume that the lower layers
> enforce some ability to memcpy it blindly. So I'd just favor using cpu order
> as soon and as much as possible.
> 
> Of course it's your driver, whence your maintenance choices.

I will re-work it soon! Thanks
