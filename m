From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [NIU] Determine the # of ports from the card's VPD
 data.
Date: Wed, 23 Apr 2008 18:28:48 -0700 (PDT)
Message-ID: <20080423.182848.74720455.davem@davemloft.net>
References: <200804231811.m3NIBhQl043628@sr1-umpk-33.sfbay.sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matheos.worku@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752176AbYDXB2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 21:28:50 -0400
In-Reply-To: <200804231811.m3NIBhQl043628@sr1-umpk-33.sfbay.sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <matheos.worku@sun.com>
Date: Wed, 23 Apr 2008 10:10:52 -0700

> +#define NIU_BMD_MATCHES(np, md_str) \
> +  (!strncmp(np->vpd.board_model, md_str, strlen(md_str)))

Why is this special construct necessary?  How can anyone tell the
reason this is needed by reading this code?

Plain ole' strcmp() should suffice.  If the string length is
different, we should get a comparison failure.  We've also made sure
that the board_model[] field is a properly null terminated string.

Is the issue that there could be some spurious trailing characters in
the board_model[] string that we'd like to ignore?

If that's the case this comparison deserves it's own small function,
with some descriptive text, rather than an ugly and undescriptive
macro.

Something like:

/* Board model strings can have trailing characters we wish
 * to ignore during comparison, for example:
 *
 *	XXXX (add example(s) here) XXX
 */
static int niu_board_model_compare(struct niu *np, const char *model)
{
	return strncmp(np->vpd.board_model, model, strlen(model));
}

Thanks.
