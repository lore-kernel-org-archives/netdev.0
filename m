From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 14:41:22 +0100
Message-ID: <20070718144122.00f28346@oldman>
References: <200707181527.38895.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpurdie@rpsys.net
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37140 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752479AbXGRNlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 09:41:46 -0400
In-Reply-To: <200707181527.38895.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 15:27:38 +0200
Florian Fainelli <florian.fainelli@telecomint.eu> wrote:

> Hi all,
> 
> This patch adds a new LED trigger, based on network activity. It gathers 
> activity from net/core/dev.c and can be used as a LED trigger by 
> specifying "network-activity". Further version should allow the user to 
> specify the network interface to bind a LED to. This trigger is a "simple" 
> trigger as defined by the LED subsystem.
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
> -- 

You are slowing down the network receive path even if LED is not used.

Doing mod_timer() is expensive, on a busy system you would be adding
another lock roundtrip and list operation for each incoming packet.
