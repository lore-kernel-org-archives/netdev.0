From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] Extended Generic Packet Classifier
Date: Sun, 27 Jul 2003 00:59:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030726225929.GF19908@rei.rakuen>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

I'd be glad to hear your thoughts about this.

The following is a short summary of:
http://tgr.kaosu.ch/egp/concept.ps

The Extended Generic Packet Classifier (EGP) is something like an
extended U32 classifier.

An EGP filter consists of 1..n keys which can be chained
together using logic AND and OR operators.

A Key can also be a container for 1..n subkeys:
  
  key1 AND ( key2 OR key3 )

A key can match data with the operators: equal, not-equal, bigger-than,
and lesser-than for 8, 16, and 32 bit pieces in a packet.

An offset (offset inside the packet to select the bits to be matched)
consists of multiple offset elements which can be either constant or
dynamic (see below) which are then calculated together with
either { + | - | * }

A dynamic offset element uses bits of the packet such as IHL.

A bitmask and shift operator can be applied to all bits from the
packet used for calculation.


Examples (Using reference implementation)

Matches TCP packets to port 22:
egp match u8 eq 6 at 9 and u16 eq 22 at u8 mask 0xf at 0 * 4 + 2

Matches TCP/UDP packets originating from 192.168.23.3:
egp match u32 eq 0xc0a81703 at 12 and ( u8 eq 6 at 9 or u8 eq 17 at 9 )

Matches TCP packets to 192.168.23.12 or UDP packets to 192.168.23.3:
egp match ( u8 eq 6 at 9 and u32 eq 0xc0a81703 at 16 ) \
    or ( u8 eq 17 at 9 and u32 0xc0a8170c at 16 )


Reference implementation:
Patch against 2.6.0-test1 and iproute2 can be found at:
http://tgr.kaosu.ch/egp/

NOTE: The implementation is done in a straight forward way
and not fully tested.

I did the project on a self-interest motivation but I'm willing
to work further on it if interests are there.

Kind Regards

-- 
Thomas GRAF
http://tgr.kaosu.ch/
