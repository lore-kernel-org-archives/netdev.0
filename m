From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Thu, 31 Jul 2008 08:42:53 +0100
Message-ID: <1217490173.3454.47.camel@pmac.infradead.org>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
	 <1217248585.22789.58.camel@obelisk.thedillows.org>
	 <1217253260.17632.6.camel@jaswinder.satnam>
	 <1217295498.28682.16.camel@obelisk.thedillows.org>
	 <1217347786.2885.11.camel@jaswinder.satnam>
	 <1217395511.31350.6.camel@obelisk.thedillows.org>
	 <1217400251.2595.3.camel@jaswinder.satnam>
	 <1217475466.16202.15.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jaswinder Singh <jaswinder@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48411 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbYGaHm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 03:42:57 -0400
In-Reply-To: <1217475466.16202.15.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 23:37 -0400, David Dillow wrote:
> request_firmware()'s mutex is protecting against things inside of that
> subsystem, but offers no protection between the test on typhoon_fw !=
> NULL and the setting of it inside of the firmware loader. That
> requires locking at a higher level.
> 
> Anyways, probing is single threaded and I seem to recall it being
> unlikely to be made parallel due to the number issues exposed last
> time, so a minimal comment is fine.

An alternative approach is to make request_firmware() do the duplicate
avoidance for itself. Since we made fw->data const (as 'fw' itself
always was), no users should be changing anything in the requested
firmware. It can be safely reused by generic code.

That simplifies the logic in drivers -- they just request what they
want, as many times as they want it, and don't have to care about the
potential duplication.

-- 
dwmw2

