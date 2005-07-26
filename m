From: "Simon Barber" <simon@devicescape.com>
Subject: RE: Why is packet socket checked before bridge in netif_receive_skb?
Date: Tue, 26 Jul 2005 14:22:54 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F6AF071@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok - and I'm guessing that the behavior is different for the protocol
specific case (i.e. packet socket bound to a specific protocol type)
because no application has needed it to be the same? (IE sniffers
normally bind to all protocols, and protocol specific apps like DHCP
servers don't need to see frames before the bridge hook - they would
normally see them on the brige itself).

Simon
 

-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, July 26, 2005 12:59 PM
To: Simon Barber
Cc: netdev@oss.sgi.com
Subject: Re: Why is packet socket checked before bridge in
netif_receive_skb?

From: "Simon Barber" <simon@devicescape.com>
Subject: Why is packet socket checked before bridge in
netif_receive_skb?
Date: Tue, 26 Jul 2005 11:03:17 -0700

> The protocol handlers are also used to implement packet sockets. - Why

> is the all handler checked before the bridge hook?

Because we want packet sniffers to see the packet before the bridging
layer decapsulates it.
