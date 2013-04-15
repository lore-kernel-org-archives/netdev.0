From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next 1/4] bnx2x: refactor nvram read procedure
Date: Mon, 15 Apr 2013 07:14:26 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20C03E5D@SJEXCHMB06.corp.ad.broadcom.com>
References: <1365843411-27103-1-git-send-email-dmitry@broadcom.com>
 <1365843411-27103-2-git-send-email-dmitry@broadcom.com>
 <20130413110916.GA20436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1594 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124Ab3DOHOf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 03:14:35 -0400
In-Reply-To: <20130413110916.GA20436@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Saturday, April 13, 2013 2:09 PM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Eilon Greenstein
> Subject: Re: [PATCH net-next 1/4] bnx2x: refactor nvram read procedure
> 
> Dmitry Kravkov <dmitry@broadcom.com> :
> > introduce a parameter to allow nvram read to return
> > data in BE or cpu order.
> [...]
> > @@ -1295,10 +1296,14 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
> >  		if (val & MCPR_NVM_COMMAND_DONE) {
> >  			val = REG_RD(bp, MCP_REG_MCPR_NVM_READ);
> >  			/* we read nvram data in cpu order
> > -			 * but ethtool sees it as an array of bytes
> > +			 * but ethtool uses it as an array of bytes
> >  			 * converting to big-endian will do the work
> > +			 * if requested.
> 
> You memcpy a u32 to an array of bytes instead of copying it byte after
> byte with proper shift operators and now you are paving the way for more
> endianess headaches. I'd rather avoid the memcpy when readying data for
> ethtool in the first place.
In case of _be data I don't see any issue with copying _be32 it into byte array.
When internal driver function (not exposed to external usage) requests data in CPU order - it meant to bring u32 data ( or array of u32) and memcpy dword by dword also should be harmless.
 
> Nit: the true/false method parameter style in middle layers is mildly
> readable when compared to usual _{be/le} kernel style (you should be
> able to avoid both almost completely anyway :o) ).
Boolean parameter used to share pre- and post-configuring nvram for read operation.
_be/le is less suitable here, since the usage is BE or cpu order.
I was thinking about separating stream read and u32 read to separate callbacks, but this will add another level and this is less preferable than true/false param.
 
> --
> Ueimor
