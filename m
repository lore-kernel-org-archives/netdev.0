From: "Eble, Dan" <DanE@aiinet.com>
Subject: RE: RFC: Cisco HDLC bridging
Date: Wed, 16 Jun 2004 08:58:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C060DFCD9697A842B3189B458524FDC205D2CD@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Krzysztof Halasa'" <khc@pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Krzysztof Halasa [mailto:khc@pm.waw.pl] 
> Sent: Wednesday, June 16, 2004 7:14 AM
... 
> Sure. But we won't - with device type = Cisco HDLC tcpdump 
> will be happy.
> I.e. will happily print SLARPs, regular IP frames, and 
> Ethernet frames.

Ah, yes.  But if the device does not have ARPHRD_ETHER the bridge driver
will not allow it to be used as a port.  I do not know what else may require
ARPHRD_ETHER, but I'm not keen to find out by trial and error (and then fix
everything to work with ARPHRD_CISCO too).

> It could be useful - with bridged Ethernet for MS Windows connectivity
> and with routed IP traffic.

When all you have is a hammer, MS Windows looks like a nail. :-)

> I'd go with "2 devices" path for now.

It is going well so far.  I will post patches when I am done, but they
probably will not apply to the current public versions without some extra
work.

This is the sethdlc syntax I have chosen to create and destroy the hdlcXeth0
device:

	sethdlc hdlc0 cisco proto <type> [ enable | disable ]

Where <type> is 0x6558 for bridged ethernet packets (or maybe "ether", but I
have not put that in yet).  I figure this will be useful to enable and
disable other protocols too.
-- 
Dan Eble <dane@aiinet.com>  _____  .
Software Engineer          |  _  |/|
Applied Innovation Inc.    | |_| | |
http://www.aiinet.com/     |__/|_|_|
