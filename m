From: Nikhil Agarwal <hi2nikhil@gmail.com>
Subject: Fwd: Memory exhaust issue with only IPsec policies configured on
 continuous traffic
Date: Thu, 10 May 2012 10:53:20 +0530
Message-ID: <CAETiZ-QvamMJxfGJDK4CiKngELNevmOXnh7M=UGnkH61XrT5dw@mail.gmail.com>
References: <F0B93D0554724543876B9A180DC988575B8867@039-SN1MPN1-001.039d.mgd.msft.net>
 <CAETiZ-QTWN2U=hmaCS39Q8hzNysjam+eS5FSi-EYO7cXtTbGKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, benjamin.thery@bull.net,
	davem@davemloft.net, eric.dumazet@gmail.com, pstaszewski@itcare.pl
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAETiZ-QTWN2U=hmaCS39Q8hzNysjam+eS5FSi-EYO7cXtTbGKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

Can you please help on this?

Regards
Nikhil

-----Original Message-----
=46rom: Agarwal Nikhil-B38457
Sent: Wednesday, May 09, 2012 2:53 PM
To: linux-kernel@vger.kernel.org; netdev@vger.kernel.org
Subject: Memory exhaust issue with only IPsec policies configured on
continuous traffic

Hi all,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 In a typical scenario, when =
IPSEC policies are
configured in the system but SA is not present or negotiation fails or
IKE daemon is not running. =A0The current behavior of xfrm is to send
those matching packets to blackhole route.=A0 i.e. xfrm_bundle_lookup
returns a bundle with null route and xfrm_lookup returns a blackhole
route.

=46or each of these packet a dst_alloc is called in
ipv4_blackhole_route. However when these skbs get free and their dst's
get discarded using dst_free and the garbage collector is scheduled
using cancel_delayed_work and schedule_delayed_work.

If the packets are coming continuously garbage collector may not get
scheduled and large amount of memory is stuck to be freed causing the
system to go into non-recoverable state.

Any ideas?

Regards
Nikhil
