From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex
 forced mode
Date: Fri, 17 Dec 2010 11:57:03 -0800 (PST)
Message-ID: <20101217.115703.183049944.davem@davemloft.net>
References: <AANLkTi=-MRrH1nCcbzqUMoP1sd=7opNGAz7KwmdoMmjA@mail.gmail.com>
	<4D0A5BBF.7000400@computer.org>
	<AANLkTimVVV76MRn1H8U6nA4V-A7a6WpR2eWgc+mCHjRv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan.ceuleers@computer.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: davidlv.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53162
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755794Ab0LQT4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 14:56:35 -0500
In-Reply-To: <AANLkTimVVV76MRn1H8U6nA4V-A7a6WpR2eWgc+mCHjRv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lv <davidlv.linux@gmail.com>
Date: Fri, 17 Dec 2010 16:25:55 +0800

> I am very Sorry to cause you some trouble.
> There are some differences with this version and previous version.
> 
> } else if (SPD_DPX_1000_FULL != pInfo->hw.sOpts.spd_dpx) {
> +		if (SPD_DPX_AUTO == pInfo->hw.sOpts.spd_dpx) {
> 
> changed to
> 
> } else if (SPD_DPX_1000_FULL != vptr->options.spd_dpx) {
> +		if (SPD_DPX_AUTO == vptr->options.spd_dpx) {

Can you please also fix up the indentation of the code you
are adding?  The indentation of MII_REG_BITS_ON() when you split
it up into multiple lines looks terrible.

I know you want to prevent long lines, but the result is worse
than a long line.

The indentation is much deeper now because you're putting already
deeply indented code under a new conditional, the 1000_FULL test.

So to keep this from looking ugly you have two choices:

1) Use goto:

	if (SPD_DPX_1000_FULL == pInfo->hw.sOpts.spd_dpx)
		goto skip;

	existing code...

	skip:

2) Put the inner logic into a helper function, and call that when
   the new conditional passes.

Thanks.
