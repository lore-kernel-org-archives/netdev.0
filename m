From: Donald Becker <becker@scyld.com>
Subject: Re: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 18:19:27 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312151802120.2973-100000@beohost>
References: <20031215144049.7acea87e.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <greearb@candelatech.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031215144049.7acea87e.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2003, Randy.Dunlap wrote:

> On Mon, 15 Dec 2003 14:17:29 -0800 "David S. Miller" <davem@redhat.com> wrote:
> 
> | On Mon, 15 Dec 2003 12:03:58 -0800
> | Ben Greear <greearb@candelatech.com> wrote:
> | 
> | > Is there an agreed upon standard for exactly what ethernet drivers
> | > should be counting for rx-bytes and tx-bytes?  For example, should the
> | > counters include the 4-byte FCS?

Yes.

> | >  Should they include the ethernet header?

Yes, but not the preamble.
  [[ Ethernet packets have an 8 byte preamble before the station
  addresses.  It doesn't make sense to count this, as
    all modern NICs strip it off, and
    a few leading bits may be dropped at each hop
  ]]

> | It should be that all drivers use what skb->len ends up with at
> | rx/tx time.

Not quite.  The skb->len value omits the 4 byte FCS/CRC.

> | However, it is often faster to just let the hardware keep track
> | of these statistics (tg3 is one example of a chip that can do
> | this).  And sometimes these mechanisms take the FCS or whatever
> | into account and this as you note makes the numbers different.

The driver should correct, although this is non-critical.
Using hardware counters where available used to make sense, but today
it's better to have the software driver maintain the statistics.  The
only thing the hardware counters are needed for is
otherwise-unobservable errors, such as missed packets and CRC errors.

> RFC 1573:
> RFC 2233:
> RFC 1213:
> all agree that on an "interface" the number of octets received (InOctets)
> is:
>  The total number of octets received on the interface, including
>  framing characters.

This is imprecise.  "Framing" might be misread to include the preamble,
which should be omitted from the count.

The original Linux errors counters were influenced by what the dp8390
chip reported.  Later, the definitions in appendix B of the dc21040
manual served as a more general guideline (although the software
counters were never a one-for-one copy of any specific hardware
semantics).


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
914 Bay Ridge Road, Suite 220		Scyld Beowulf cluster systems
Annapolis MD 21403			410-990-9993
