From: "Eble, Dan" <DanE@aiinet.com>
Subject: RE: RFC: Cisco HDLC bridging
Date: Mon, 14 Jun 2004 09:40:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C060DFCD9697A842B3189B458524FDC205D2C6@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Krzysztof Halasa'" <khc@pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krzysztof, I thought you had dropped off the face of the earth.  Good to
hear from you again.  Did you ever see my changes to make the HDLC generic
layer use the PPP generic layer instead of syncppp.c?

> obvious to newcomers. And I would make it conditional (for example,
> with CONFIG_ option _and_ runtime ioctl creating the slave device).

OK.  I will attempt to add CONFIG_HDLC_CISCO_ETH and IF_PROTO_CISCO_ADD_ETH.
IF_PROTO_CISCO_ADD_ETH will return the name of the new device, probably
"hdlcXeth0".

> How are the packets encapsulated? What about 802.1q VLANs?

The packets are put directly into the payload of the Cisco HDLC frame.  The
protocol number in the Cisco header is 0x6558.  I don't remember if the FCS
is included or not.  I expect it is, but that should be obvious when I hook
up to a Cisco device.

I'm not sure about VLAN frames, or about IEEE spanning tree; I plan to treat
them like all other packets until I learn that there is another way.

> However I don't feel like convinced to use the second network device.
> Certainly there is no problem with tcpdump/libpcap, we could have
> Cisco hdlcX device with SLARPs, Ethernet framing, regular IPv4/6
> and anything we want.

I thought tcpdump/libpcap only looked at the device type, so that if we sent
non-eth packets up an eth interface, tcpdump would try to interpret them as
eth packets.  My primary reason for wanting a second device is to be sure
not to discard information that is helpful/necessary for troubleshooting;
so, if receiving packets with diverse header types is not going to mess
things up, I would definitely prefer using only one device, because it is
simpler to configure.  The case of using a Cisco HDLC link for bridged
ethernet *and* IP *and* other things at the same time does not seem very
useful.

> The only problem I can see (a serious one, though) is the protocol
> "routing" in Linux. If we "ip addr add" IP address to hdlcX, does
> it mean we want native IP or IP/Ethernet? It would be nice to be able
> to:
>         ifconfig hdlc0 10.0.0.1/24 hw cisco-hdlc
>         ifconfig hdlc0 10.0.1.1/24 hw ether

We could just use "sethdlc hdlc0 cisco-eth" and not worry about
distinguishing in ifconfig, right?
