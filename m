From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] [NET]: Rethink mark field in struct flowi
Date: Thu, 09 Nov 2006 15:21:17 -0800 (PST)
Message-ID: <20061109.152117.78382280.davem@davemloft.net>
References: <20061109112735.577771022@lsx.localdomain>
	<20061109113245.573179984@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28564
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424253AbWKIXVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:21:08 -0500
To: tgraf@suug.ch
In-Reply-To: <20061109113245.573179984@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 09 Nov 2006 12:27:37 +0100

> Now that all protocols have been made aware of the mark
> field it can be moved out of the union thus simplyfing
> its usage.
> 
> The config options in the IPv4/IPv6/DECnet subsystems
> to enable respectively disable mark based routing only
> obfuscate the code with ifdefs, the cost for the
> additional comparison in the flow key is insignificant,
> and most distributions have all these options enabled
> by default anyway. Therefore it makes sense to remove
> the config options and enable mark based routing by
> default.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, and I moved the mark in the flowi up to the top right after
oif/iif in order to make sure it's in the same 32-byte cache line with
the ipv4 addressing.
