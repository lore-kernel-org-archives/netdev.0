From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/4] bnx2x: refactor nvram read procedure
Date: Sat, 13 Apr 2013 13:09:16 +0200
Message-ID: <20130413110916.GA20436@electric-eye.fr.zoreil.com>
References: <1365843411-27103-1-git-send-email-dmitry@broadcom.com>
 <1365843411-27103-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43114 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab3DMLJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 07:09:23 -0400
Content-Disposition: inline
In-Reply-To: <1365843411-27103-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Kravkov <dmitry@broadcom.com> :
> introduce a parameter to allow nvram read to return
> data in BE or cpu order.
[...]
> @@ -1295,10 +1296,14 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
>  		if (val & MCPR_NVM_COMMAND_DONE) {
>  			val = REG_RD(bp, MCP_REG_MCPR_NVM_READ);
>  			/* we read nvram data in cpu order
> -			 * but ethtool sees it as an array of bytes
> +			 * but ethtool uses it as an array of bytes
>  			 * converting to big-endian will do the work
> +			 * if requested.

You memcpy a u32 to an array of bytes instead of copying it byte after
byte with proper shift operators and now you are paving the way for more
endianess headaches. I'd rather avoid the memcpy when readying data for
ethtool in the first place.

Nit: the true/false method parameter style in middle layers is mildly
readable when compared to usual _{be/le} kernel style (you should be
able to avoid both almost completely anyway :o) ).

-- 
Ueimor
