From: David Miller <davem@davemloft.net>
Subject: Re: [net-next RFC] net: ipv4: Send IGMP messages from highest
 scoped address
Date: Tue, 18 Aug 2015 12:01:10 -0700 (PDT)
Message-ID: <20150818.120110.838819870003861953.davem@davemloft.net>
References: <1439827764-29129-1-git-send-email-andrew@lunn.ch>
	<20150817.213158.1038537149649115817.davem@davemloft.net>
	<20150818133641.GB4381@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbHRTBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:01:11 -0400
In-Reply-To: <20150818133641.GB4381@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 18 Aug 2015 15:36:41 +0200

> We currently take the first address from the interface which is scope
> link or higher.
> 
> Historically, the global scope address would of been used, but my
> previous fix, which stopped it taking a global scope address from a
> different interface altogether under some conditions, changed this
> behaviour.
> 
> The first address from the interface, then broke one of my use
> case. The querier is only in one of the subnets on this interface, and
> using an address from the global scope address range. It then drops
> the membership reports when they are sent from the first address on
> the interface. This is why i want to restore the previous behaviour,
> take the global scope address from this interface.
> 
> The patch works for me and is restoring previous behaviour, but is
> that sufficient to make it correct?

Preferring link-scope addresses make so much more sense for me.

The querier is on the local network, and he can do things like the
validity check on the subnet of the source address to try and avoid
forged IGMP responses.

So if anything I'd be advising you to change the code to prefer
link local addresses on the interface and keep avoiding global
addresses, as it is the only correct source address selection
scheme I can think of for IGMPs.
