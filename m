From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Feature suggestion - ability to disable broadcast reception on
 ethernet interfaces
Date: Fri, 19 Nov 2004 12:57:47 +1030
Message-ID: <20041119125747.47c80c0d.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'd like to suggest a feature which could be useful to people attaching
IPv6 only nodes to mixed IPv4 and IPv6 (and other layer 3 protocol) LANs
- the ability to disable reception of ethernet broadcast frames on an
IPv6 only interface. It would also be useful to people running Appletalk
only interfaces, as I'm pretty sure Appletalk only uses multicasts for
address resolution etc, or those small number of people who might want
to simulate a non-broadcast multiple access network when playing with
routing protocols.

The main benefit would be to avoid broadcast frames from causing
interrupts on nodes that have no interest in them. I've worked on some
large LANs which have a large number of broadcast frames, caused by IPv4
and IPX (10MB of data in broadcast frames within 25 minutes is very
scary!). While these were certainly networks that should be redesigned,
I think it would be useful for (linux) nodes that weren't interested in
receiving broadcasts to either ignore them by default, or be able to be
configured to ignore them.

I've looked up the spec sheets for a few of the ethernet chips / cards I
have (NS8390 used on NE2K, SMSC LAN83C171 used on SMC EPIC100, NS83815
used on Netgear FA311/FA312), and it appears that broadcast address
recognition is an option that is separately settable to unicast and
multicast address recognition. I'm not sure if this is representative of
the majority of ethernet chipsets, although with these
cards being commodity cards, ranging over quite a number of years of
design and manufacture, I'd think being able to separately enable
/ disable broadcast address recognition would probably be a common
feature for a lot of ethernet chipsets.

Rather than it being an interface "layer 2" specific switch or option,
another way to implement it could be similar to the way Novell Netware
works when it comes to enabling layer 3 protocols on a layer 2
interfaces. Under Novell Netware, if you want to enable IPv4 on an
interface, you need to"bind" IPv4 to the interface. Other interfaces on
the Netware server won't process packets for the "bound" protocol. I'm
not sure if this happens on Novell Netware, however, I could see how
when a layer 3 protocol is bound to a layer 2 interface, a set of
required address recognition features (i.e., unicast, multicast,
broadcast) are passed down to the device driver, which the device driver
then enables on the card itself. For example, if IPv6 was bound to an
interface, IPv6 would request only unicast and multicast address
recognition from the interface device driver. An IPv6 only interface
would then ignore any ethernet broadcast frames. If IPv4 was then bound
to the same interface, it would request unicast and broadcast address
recognition, and optionally multicast address recognition if IPv4
multicast was supported. The device driver would then also enable
broadcast address recognition to allow IPv4 to work in conjunction with
IPv6.

I'd love to have a go at implementing this my self, unfortunately I
don't know anywhere near enough C or kernel programming to do so. The
suggestion is the best I can do at the moment, other than testing. If
somebody with the right skills and time thinks this idea would be
useful, I'm certainly quite willing to spend time testing any
preliminary implementation.

Thanks,
Mark.
