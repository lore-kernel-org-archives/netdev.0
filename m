From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: RFC: Cisco HDLC bridging
Date: Fri, 11 Jun 2004 23:29:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3vfhxkcm3.fsf@defiant.pm.waw.pl>
References: <C060DFCD9697A842B3189B458524FDC205D2C3@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eble, Dan" <DanE@aiinet.com>
In-Reply-To: <C060DFCD9697A842B3189B458524FDC205D2C3@AIMAIL1.ai.aiinet.com> (Dan
 Eble's message of "Fri, 11 Jun 2004 09:01:20 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Eble, Dan" <DanE@aiinet.com> writes:

> I am about to implement Ethernet/802.3 over Cisco HDLC.  My plan is to
> enhance hdlc_cisco.c to provide a new ethernet-like device, "cbeX"
> (cisco-bridged ethernet),

I would rather call it "hdlcXsomething", "cbeX" would not be very
obvious to newcomers. And I would make it conditional (for example,
with CONFIG_ option _and_ runtime ioctl creating the slave device).

> corresponding to the existing "hdlcX" device that
> encapsulates the ethernet frames.  The "cbeX" device will suddenly appear
> when "sethdlc hdlcX cisco ..." is run, and disappear when "hdlcX" is taken
> out of Cisco mode.

How are the packets encapsulated? What about 802.1q VLANs?

> Using a separate device for the bridged frames provides a way to get
> ethernet-like behavior without obscuring the Cisco nature of "hdlcX".  For
> example, a tcpdump of "hdlcX" would still show SLARP keepalive frames and
> other ciscoey stuff.

... + Ethernet traffic with Cisco HDLC headers, that's it.

However I don't feel like convinced to use the second network device.
Certainly there is no problem with tcpdump/libpcap, we could have
Cisco hdlcX device with SLARPs, Ethernet framing, regular IPv4/6
and anything we want.

The only problem I can see (a serious one, though) is the protocol
"routing" in Linux. If we "ip addr add" IP address to hdlcX, does
it mean we want native IP or IP/Ethernet? It would be nice to be able
to:
        ifconfig hdlc0 10.0.0.1/24 hw cisco-hdlc
        ifconfig hdlc0 10.0.1.1/24 hw ether
at a time.

The same applies to Frame Relay (we have pvcX and ethpvcX).
-- 
Krzysztof Halasa, B*FH
