From: "Eble, Dan" <DanE@aiinet.com>
Subject: RFC: Cisco HDLC bridging
Date: Fri, 11 Jun 2004 09:01:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C060DFCD9697A842B3189B458524FDC205D2C3@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greetings network geeks,

I am about to implement Ethernet/802.3 over Cisco HDLC.  My plan is to
enhance hdlc_cisco.c to provide a new ethernet-like device, "cbeX"
(cisco-bridged ethernet), corresponding to the existing "hdlcX" device that
encapsulates the ethernet frames.  The "cbeX" device will suddenly appear
when "sethdlc hdlcX cisco ..." is run, and disappear when "hdlcX" is taken
out of Cisco mode.

Using a separate device for the bridged frames provides a way to get
ethernet-like behavior without obscuring the Cisco nature of "hdlcX".  For
example, a tcpdump of "hdlcX" would still show SLARP keepalive frames and
other ciscoey stuff.

I had also considered simply making "hdlcX" look like an ethernet device,
and "preserving" the SLARP packets for tcpdump by prepending a phony
ethernet header.  I abandoned that design because I could not find an
appropriate ethertype to mark such packets.  (It has other drawbacks too,
but at least it would be simple.)

Comments, suggestions, and warnings are welcome.

-- 
Dan Eble <dane@aiinet.com>  _____  .
Software Engineer          |  _  |/|
Applied Innovation Inc.    | |_| | |
http://www.aiinet.com/     |__/|_|_|
