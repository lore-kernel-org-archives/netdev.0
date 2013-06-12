From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Davicom DM9000A regression
Date: Wed, 12 Jun 2013 23:23:06 +0200
Message-ID: <20130612212306.GA21234@electric-eye.fr.zoreil.com>
References: <51B87A19.4030708@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, josright123@gmail.com
To: Nikita Kiryanov <nikita@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46446 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755908Ab3FLVXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 17:23:14 -0400
Content-Disposition: inline
In-Reply-To: <51B87A19.4030708@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikita Kiryanov <nikita@compulab.co.il> :
[...]
> A bit of digging revealed the cause as this patch:
> "DM9000B: driver initialization upgrade"

(aka 6741f40d198c6a5feb23653a1efd4ca47f93d83d)

> and specifically, the following line that was added by it:
> dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET); /* PHY RESET */
> (uncommenting this line solves the problem).
> Adding a delay after the phy reset did not help.

(I have no idea why Davicom enforced a dsp phy register write everywhere
instead of using db->type to identify the specific chipset revision that
requires it)

The last version of the patch changed - not much - without notice and
it did not contain the "tested on DM9000{A, B, E}, x86, arm" part.

You may try http://marc.info/?l=linux-netdev&m=136443908225335 to
see if it behaves the same.

-- 
Ueimor
