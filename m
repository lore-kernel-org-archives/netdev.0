From: David Miller <davem@davemloft.net>
Subject: Re: [patch for 2.6.28? 1/1] b1isa: fix b1isa_exit() to really
 remove registered capi controllers
Date: Wed, 03 Dec 2008 20:57:45 -0800 (PST)
Message-ID: <20081203.205745.127195542.davem@davemloft.net>
References: <20081202114926.GA21919@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@lebenslange-mailadresse.de, calle@calle.de,
	stable@kernel.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54686
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751993AbYLDE5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 23:57:45 -0500
In-Reply-To: <20081202114926.GA21919@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@suse.de>
Date: Tue, 2 Dec 2008 12:49:26 +0100

> On "/etc/init.d/capiutils stop", this oops happened.
> 
> The oops happens on reading /proc/capi/controllers because
> capi_ctrl->procinfo is called for the wrongly not unregistered
> controller, which points to b1isa_procinfo(), which was removed on
> module unload.
> 
> b1isa_exit() did not call b1isa_remove() for its controllers because
> io[0] == 0 on module unload despite having been 0x340 on module load.
> 
> Besides, just removing the controllers that where added on module
> load time and not those that were added later via b1isa_add_card() is
> wrong too - the place where all added cards are found is isa_dev[].
 ...
> Signed-off-by: Wilfried Klaebe <linux-kernel@lebenslange-mailadresse.de>
> Cc: <calle@calle.de>
> Cc: <stable@kernel.org> 	[2.6.everything]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Karsten Keil <kkeil@suse.de>

Patch applied, thanks.
