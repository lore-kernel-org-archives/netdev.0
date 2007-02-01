From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 hangs
Date: Thu, 1 Feb 2007 14:58:15 -0800
Message-ID: <20070201145815.199bfe1a@freekitty>
References: <20070201185532.GL13130@cip.informatik.uni-erlangen.de>
	<42007.80.98.159.250.1170369983.squirrel@www.hunhost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <thomas@glanzmann.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Fagyal Csongor" <concept@conceptonline.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46597 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422686AbXBAXBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 18:01:14 -0500
In-Reply-To: <42007.80.98.159.250.1170369983.squirrel@www.hunhost.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I can reproduce the problem now (on mac mini). Interestingly it seems to whack
the whole ethernet switch when it happens.
> 
> - a previously suggested fix - passing idle=poll to the kernel - did not
> work for me at the end

It is not an MSI or IRQ problem. It is a phy problem (see below).

> - the locks I have happen very periodically (somewhere around every 22-28
> hours), as if the chip would die after a given amount of data transferred;
> I know this looks stupid but I thought I might mention it
> - I have about 1Mbit/s of (incoming) traffic on this interface: with
> short, very high peaks, as there is a MySQL server on the other end,
> receiving about 100 queries per second
> - unloading the sky2 module totally freezes the computer for me

If you do:
	ethtool -r eth0
it cause a PHY reset (renegotiation) and clears the problem.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
