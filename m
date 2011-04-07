From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] cxgb4: don't hold RTNL during ethtool phys_id
Date: Thu, 07 Apr 2011 01:35:23 +0100
Message-ID: <1302136523.2935.182.camel@localhost>
References: <20110406170929.6e427b36@nehalam>
	 <201104061720.30219.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Dimitris Michailidis <dm@chelsio.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39648 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745Ab1DGAf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 20:35:28 -0400
In-Reply-To: <201104061720.30219.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-06 at 17:20 -0700, Casey Leedom wrote:
> | From: Stephen Hemminger <shemminger@linux-foundation.org>
> | Date: Wednesday, April 06, 2011 05:09 pm
> | 
> | The Chelsio cxgb4 drivers implement blinking in a unique way by
> | waiting on the mailbox. This patch cleans it up slightly by no longer
> | holding the system wide network configuration lock during the process.
> | 
> | The patch also uses correct semantics for the time argument
> | which is supposed to be in seconds; and zero is supposed
> | to signify infinite blinking.
> | 
> | This is still a bad firmware interface design for this
> | since it means the board is basically hung while doing the blink.
> | But fixing it correctly would require hardware and firmware
> | documentation. With that information the device could be converted
> | to the new set_phys_id.
> | 
> | Compile tested only.
> | 
> | Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
>   Are you assuming that the firmware won't respond with a command completion 
> until the LED blinking is complete?  If so, that's a bad assumption.  The 
> firmware runs as an asynchronous real-time OS.  The LED blinking simply becomes 
> a thread of activity within the OS and the command completes immediately.
[...]

Stephen was assuming (as I did) that you actually implemented this
operation correctly.  You're supposed to blink the LED for the specified
time but let the user interrupt early.  If you just start the LED
blinking and then return, then it appears the user has no way to
interrupt it.

Is there a defined firmware command to stop blinking the LED?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

