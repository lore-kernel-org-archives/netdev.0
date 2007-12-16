From: David Miller <davem@davemloft.net>
Subject: Re: [RFT] tehuti: napi fix
Date: Sun, 16 Dec 2007 13:38:33 -0800 (PST)
Message-ID: <20071216.133833.105913775.davem@davemloft.net>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	<20071212.071832.07747779.davem@davemloft.net>
	<20071212135852.3369c820@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	baum@tehutinetworks.net, andy@greyhouse.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50298
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756058AbXLPVim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:38:42 -0500
In-Reply-To: <20071212135852.3369c820@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 12 Dec 2007 13:58:52 -0800

> This should fix the tehuti napi fence post problems by getting
> rid of priv->napi_stop, and setting weight to 32 (like other 10G).
> 
> Also, used the wierd entry/exit macro's like rest of driver.

It fixes the fench-post problem, but like the comments you
removed explain:

> -		/* from time to time we exit to let NAPI layer release
> -		 * device lock and allow waiting tasks (eg rmmod) to advance) */
> -		priv->napi_stop = 0;
> -

We now hang on rmmod during constant packet load.

This change just trades one bug for another, we have to
get the device close issue sorted out before we can go
around removing these things.
