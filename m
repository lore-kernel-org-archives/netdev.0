From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Add support for PHY packet generators
Date: Thu, 18 Feb 2016 15:45:39 -0500 (EST)
Message-ID: <20160218.154539.340432973192973342.davem@davemloft.net>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425560AbcBRUpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:45:41 -0500
In-Reply-To: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 17 Feb 2016 21:32:05 +0100

> Some Ethernet PHYs contain a simple packet generator. This can be
> useful for bringing up new devices, trying to determine if a problem
> lies in the MAC-PHY connection or PHY-Socket. Also, the PHY generators
> can generate invalid packets, which is hard to do in software.
> 
> Add support ethtool(1) and wire up the Marvell PHY packet generator.

You really cannot make this blocking, every time we've added a blocking
ethtool op that could take a non-trivial amount of time we've been
burnt.

So as Ben mentioned blocking for 0.3 seconds or whatever is a non-starter.
