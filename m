From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: RFC: Cisco HDLC bridging
Date: Wed, 16 Jun 2004 13:13:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3llinn4bb.fsf@defiant.pm.waw.pl>
References: <C060DFCD9697A842B3189B458524FDC205D2C6@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eble, Dan" <DanE@aiinet.com>
In-Reply-To: <C060DFCD9697A842B3189B458524FDC205D2C6@AIMAIL1.ai.aiinet.com> (Dan
 Eble's message of "Mon, 14 Jun 2004 09:40:23 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Eble, Dan" <DanE@aiinet.com> writes:

> Krzysztof, I thought you had dropped off the face of the earth.  Good to
> hear from you again.  Did you ever see my changes to make the HDLC generic
> layer use the PPP generic layer instead of syncppp.c?

Not sure. Do you have a copy?

> I thought tcpdump/libpcap only looked at the device type, so that if we sent
> non-eth packets up an eth interface, tcpdump would try to interpret them as
> eth packets.

Sure. But we won't - with device type = Cisco HDLC tcpdump will be happy.
I.e. will happily print SLARPs, regular IP frames, and Ethernet frames.
Looks like it doesn't support it yet:

        switch (proto) {
        case ETHERTYPE_IP:
        case ETHERTYPE_IPV6:
        case CHDLC_TYPE_SLARP:
        case CHDLC_TYPE_CDP:
        case ETHERTYPE_MPLS:
        case ETHERTYPE_MPLS_MULTI:
        case ETHERTYPE_ISO:

but I can't see a problem with adding it, given the kernel code is
confirmed working so I can test it.

Note it's irrelevant to single hdlcX vs hdlcX + hdlcXeth0 issue, it
has to be done anyway.

>  My primary reason for wanting a second device is to be sure
> not to discard information that is helpful/necessary for troubleshooting;
> so, if receiving packets with diverse header types is not going to mess
> things up, I would definitely prefer using only one device, because it is
> simpler to configure.

Receive side is definitely not a problem. Transmit side is and I think
we need two devices, at least for now.

>  The case of using a Cisco HDLC link for bridged
> ethernet *and* IP *and* other things at the same time does not seem very
> useful.

But it's more elegant solution I think (the same would apply to FR PVCs).
It could be useful - with bridged Ethernet for MS Windows connectivity
and with routed IP traffic.

>> The only problem I can see (a serious one, though) is the protocol
>> "routing" in Linux. If we "ip addr add" IP address to hdlcX, does
>> it mean we want native IP or IP/Ethernet? It would be nice to be able
>> to:
>>         ifconfig hdlc0 10.0.0.1/24 hw cisco-hdlc
>>         ifconfig hdlc0 10.0.1.1/24 hw ether
>
> We could just use "sethdlc hdlc0 cisco-eth" and not worry about
> distinguishing in ifconfig, right?

Sure, but that wouldn't be "at a time".

I'd go with "2 devices" path for now. Long-term I'm going to investigate
"1 device" possibility. This depends on my future job = time I can
find for it, as my current contract ends by Sep, 1 and I'll be seeking
a new one (hope I'll have more time for Linux works than now).
-- 
Krzysztof Halasa, B*FH
