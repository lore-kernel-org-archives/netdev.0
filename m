From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Thu, 23 Dec 2004 00:14:11 -0800
Message-ID: <B1508D50A0692F42B217C22C02D849720312DF09@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Would this condition be possible if something, such as ASF, were
> continually polling the PHY in parallel with the driver?

Without proper handshake with ASF, I think it may be possible if ASF is in a very tight loop polling the PHY. The tg3_readphy() poll loop is not very tight so it is possible to continually hit the busy condition if ASF is polling PHY registers. If this is the case, even if tg3_readphy() eventually gets the data, the data will most likely be from a different PHY register (that ASF is trying to read).
 
But I don't think this is an ASF related problem because if it were, the patch would not have fixed it.
 
Michael
