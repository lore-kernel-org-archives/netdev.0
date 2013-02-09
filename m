From: pablo@netfilter.org
Subject: [PATCH 0/5] Netfilter/IPVS fixes for 3.8-rc7
Date: Sat,  9 Feb 2013 13:03:55 +0100
Message-ID: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains Netfilter/IPVS fixes for 3.8-rc7, they =
are:

* Fix oops in IPVS state-sync due to releasing a random memory area due
  to unitialized pointer, from Dan Carpenter.

* Fix SCTP flow establishment due to bad checksumming mangling in IPVS,
  from Daniel Borkmann.

* Three fixes for the recently added IPv6 NPT, all from YOSHIFUJI Hidea=
ki,
  with an amendment collapsed into those patches from Ulrich Weber. The=
y
  fiix adjustment calculation, fix prefix mangling and ensure LSB of
  prefixes are zeroes (as required by RFC).

Specifically, it took me a while to validate the 1's complement arithme=
tics/
checksumming approach in the IPv6 NPT code.

It's fairly late stage, so let me know if you can still pull these from=
:

git://1984.lsi.us.es/nf master

Thanks!

Dan Carpenter (1):
  ipvs: freeing uninitialized pointer on error

Daniel Borkmann (1):
  ipvs: sctp: fix checksumming on snat and dnat handlers

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (3):
  netfilter: ip6t_NPT: Fix adjustment calculation
  netfilter: ip6t_NPT: Fix prefix mangling
  netfilter: ip6t_NPT: Ensure to check lower part of prefixes are zero

 net/ipv6/netfilter/ip6t_NPT.c         |   18 +++++++++++++----
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   35 ++++++++++++++++---------=
--------
 net/netfilter/ipvs/ip_vs_sync.c       |    2 ++
 3 files changed, 33 insertions(+), 22 deletions(-)

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
