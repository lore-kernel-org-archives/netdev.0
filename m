From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from IPsec-protected MIPv6 traffic
Date: Fri, 24 Sep 2010 21:18:09 +0200
Message-ID: <87bp7nrlvy.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:40704 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594Ab0IXTRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Sep 2010 15:17:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

First off, patches for discussion are in following emails. They are
*against current linux-2.6* (on which they were tested) but will be
rebased against net-next-2.6 for next round.

Simply put, the patches provides the ability to remove annoying Routing
Header Type 2 and Destination Options Header with Home Address Option
from IPsec-protected MIPv6 signaling traffic, changing on-wire format
from:


    MN  ------------ IPv6() / HAO / ESP(BU) ----------> HA
    MN  <----------- IPv6() / RH2 / ESP(BA) ----------- HA

to 

    MN  ------------ IPv6() / ESP(BU) --------------> HA
    MN  <----------- IPv6() / ESP(BA) --------------- HA


This is an *self-contained* part of a set of additional enhancements for
Mobile IPv6 when used w/ IPsec and IKE specified in IRO draft [1]. Once 
available, this can also be extended to IPsec-protected route optimized
communications between MN and CN/MN.

Among the operational benefits of the feature is the ability to run in
networks in which (dumb) firewalls drop Routing Headers (Cisco PIX
firewalls are known to do that by default and w/o ways of correcting the
issue). Anonimity is another.

Basically, RH2/HAO are only *explicit* containers for the Home Address
(HoA), which is obviously available in the IPsec stack (transport mode
SA protecting traffic use the HoA). This means that the info is
available on both sides and there is no real need to carry it explictly.

>From an implementation standpoint, some changes are required to allow
finding the SA when the addresses are not expected ones and remap them
if asked to do so (or act as usual if not). Then, most of the other
changes are basically simple versions of what can be found at the moment
for RH2 and HAO in DestOpt handling. Unlike what happens with RH2/HAO,
packets structure is never modified.

I rely on the feature on my MN (my laptop) and HA for 2 kernel versions
to provide me with connectivity (v4 networks are handled using
m6t [1]). Patches for UMIP [2] are available and will be merged upstream
if the feature gets accepted. At the moment, the people using the Debian
package for UMIP [3] can simply benefit from the feature by compiling a 
patched kernel (2.6.34 and 2.6.35.5 available [5]), and then doing a
simple apt-get remove umip && apt-get install umip-iro. 

Cheers,

a+

[1] http://tools.ietf.org/html/draft-ebalard-mext-ipsec-ro  
[2] http://natisbad.org/m6t/
[3] http://umip.org/
[4] http://umip.org/docs/umip-debrepo.html
[5] http://natisbad.org/IRO/
