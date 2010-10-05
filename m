From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch] isdn: strcpy() => strlcpy()
Date: Tue, 5 Oct 2010 17:43:06 +0100
Message-ID: <20101005164306.GP19804@ZenIV.linux.org.uk>
References: <20101005163448.GH5692@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49966 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842Ab0JEQnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 12:43:10 -0400
Content-Disposition: inline
In-Reply-To: <20101005163448.GH5692@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 05, 2010 at 06:34:48PM +0200, Dan Carpenter wrote:
> setup.phone and setup.eazmsn are 32 character buffers.
> rcvmsg.msg_data.byte_array is a 48 character buffer.
> sc_adapter[card]->channel[rcvmsg.phy_link_no - 1].dn is 50 chars.
> 
> I changed the strcpy() so strlcpy() because that's safest.

ITYM "I papered it over, so potentially broken behaviour is harder to
find now"...

> -				strcpy(setup.phone,&(rcvmsg.msg_data.byte_array[4]));
> -				strcpy(setup.eazmsn,
> -					sc_adapter[card]->channel[rcvmsg.phy_link_no-1].dn);
> +				strlcpy(setup.phone, &(rcvmsg.msg_data.byte_array[4]),
> +					sizeof(setup.phone));

OK, so what should be done if the damn array contents _is_ longer than that?

> +				strlcpy(setup.eazmsn,
> +					sc_adapter[card]->channel[rcvmsg.phy_link_no - 1].dn,
> +					sizeof(setup.eazmsn));

Ditto.

> -			strcpy(sc_adapter[card]->channel[rcvmsg.phy_link_no-1].dn,rcvmsg.msg_data.byte_array);
> +			strlcpy(sc_adapter[card]->channel[rcvmsg.phy_link_no - 1].dn,
> +				rcvmsg.msg_data.byte_array,
> +				sizeof(rcvmsg.msg_data.byte_array));

Huh?  Is it or is it not NUL-terminated?  If it is, then change is pure
cargo-culting; if it is not, you are asking for nasal daemons to fly.
