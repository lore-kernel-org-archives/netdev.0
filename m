From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4] lxt PHY: Support for the buggy LXT973 rev A2
Date: Mon, 24 Sep 2012 15:13:41 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7004@saturn3.aculab.com>
References: <201209241400.q8OE0w38011790@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Christophe Leroy" <christophe.leroy@c-s.fr>,
	"David S Miller" <davem@davemloft.net>,
	"Richard Cochran" <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <201209241400.q8OE0w38011790@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This patch adds proper handling of the buggy revision A2 of LXT973 phy, adding
> precautions linked to ERRATA Item 4:
> 
> Revision A2 of LXT973 chip randomly returns the contents of the previous even
> register when you read a odd register regularly

Does reading the PHY registers involve bit-banging an MII interface?
If so this code is likely to stall the system for significant
periods (ready phy registers at all can be a problem).

I know some ethernet mac have hardware blocks for reading MII
and even polling one MII register for changes.

Maybe some of this code ought to be using async software
bit-bang - especially when just polling for link status change.
I'm sure it ought to be possible to do one bit-bang action
per clock tick instead of spinning for the required delays. 

	David
