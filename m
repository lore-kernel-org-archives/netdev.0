From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Mon, 27 Jun 2016 10:59:12 -0700
Message-ID: <20160627105912.7961c3f4@xeon-e3>
References: <d6784d8bb2d84ceab6c1719e32e8fa8e@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:42314 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbcF0R70 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 13:59:26 -0400
In-Reply-To: <d6784d8bb2d84ceab6c1719e32e8fa8e@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2016 17:34:08 +0000
Phil Sutter <phil@nwl.cc> wrote:

> This is v3 of my C99-style initializer related patch series. The chan=
ges
> since v2 are:
>=20
> - Flattened embedded struct's initializers:
>   Since the field names are very short, I figured it makes more sense=
 to
>   keep indenting low. Also, the same style is already used in
>   ip/xfrm_policy.c so take that as an example.
>=20
> - Moved leftover nlmsg_seq initializing into the common place as well=
:
>   I was unsure whether this is a good idea at first (due to the
>   increment), but again it's done in ip/xfrm_policy.c as well so shou=
ld
>   be fine.
>=20
> - Added a comma after the last field initializer as suggested by Jaku=
b.
>=20
> - Dropped patch 7 since it was NACKed.
>=20
> - Eliminated checkpatch non-compliance.
>=20
> - Second go at union bpf_attr in tc/tc_bpf.c:
>   I figured that while it is not possible to initialize fields, gcc-3=
=2E4.6
>   does not complain when setting the whole union to zero using '=3D {=
0}'.
>   So I did this and thereby at least got rid of the memset calls.
>=20
> For reference, here's the v2 changelog:
>=20
> - Rebased onto current upstream master:
>   My own commit a0a73b298a579 ("tc: m_action: Use C99 style initializ=
ers
>   for struct req") contains most of the changes to tc/m_action.c alre=
ady,
>   so I put the remaining ones into a dedicated patch (the first one h=
ere)
>   with a better description.
>=20
> - Tested against gcc-3.4.6:
>   This is the oldest gcc version I was able to install locally. It in=
deed
>   does not like the former changes in tc/tc_bpf.c, so I reverted them=
=2E
>   Apart from emitting many warnings, it successfully compiles the
>   sources.
>=20
> In the process of compatibility testing, I made a few more changes wh=
ich
> make sense to have:
>=20
> - New patch 5 allows to conveniently override the compiler via comman=
d
>   line.
>=20
> - New patch 6 eliminates a warning with old gcc but looks valid in
>   general.
>=20
> - A warning made me look at ip/tcp_metrics.c and I found a minor code
>   simplification (patch 7).
>=20
> Phil Sutter (6):
>   tc: m_action: Improve conversion to C99 style initializers
>   Use C99 style initializers everywhere
>   Replace malloc && memset by calloc
>   No need to initialize rtattr fields before parsing
>   Makefile: Allow to override CC
>   misc/ifstat: simplify unsigned value comparison
>=20
>  Makefile           |   4 +-
>  bridge/fdb.c       |  25 ++++++------
>  bridge/link.c      |  14 +++----
>  bridge/mdb.c       |  17 ++++-----
>  bridge/vlan.c      |  17 ++++-----
>  genl/ctrl.c        |  44 +++++++++------------
>  genl/genl.c        |   3 +-
>  ip/ip6tunnel.c     |  10 ++---
>  ip/ipaddress.c     |  33 +++++++---------
>  ip/ipaddrlabel.c   |  21 ++++------
>  ip/iplink.c        |  61 ++++++++++++-----------------
>  ip/iplink_can.c    |   4 +-
>  ip/ipmaddr.c       |  25 ++++--------
>  ip/ipmroute.c      |   8 +---
>  ip/ipneigh.c       |  30 ++++++---------
>  ip/ipnetconf.c     |  10 ++---
>  ip/ipnetns.c       |  39 +++++++++----------
>  ip/ipntable.c      |  25 ++++--------
>  ip/iproute.c       |  78 +++++++++++++------------------------
>  ip/iprule.c        |  22 +++++------
>  ip/iptoken.c       |  19 ++++-----
>  ip/iptunnel.c      |  31 +++++----------
>  ip/ipxfrm.c        |  26 ++++---------
>  ip/link_gre.c      |  18 ++++-----
>  ip/link_gre6.c     |  18 ++++-----
>  ip/link_ip6tnl.c   |  25 +++++-------
>  ip/link_iptnl.c    |  22 +++++------
>  ip/link_vti.c      |  18 ++++-----
>  ip/link_vti6.c     |  18 ++++-----
>  ip/xfrm_policy.c   |  99 +++++++++++++++++++------------------------=
----
>  ip/xfrm_state.c    | 110 ++++++++++++++++++++++---------------------=
----------
>  lib/libnetlink.c   |  77 ++++++++++++++-----------------------
>  lib/ll_map.c       |   1 -
>  lib/names.c        |   7 +---
>  misc/arpd.c        |  64 ++++++++++++++-----------------
>  misc/ifstat.c      |   2 +-
>  misc/lnstat.c      |   6 +--
>  misc/lnstat_util.c |   4 +-
>  misc/ss.c          |  37 +++++++-----------
>  tc/e_bpf.c         |   7 +---
>  tc/em_canid.c      |   4 +-
>  tc/em_cmp.c        |   4 +-
>  tc/em_ipset.c      |   4 +-
>  tc/em_meta.c       |   4 +-
>  tc/em_nbyte.c      |   4 +-
>  tc/em_u32.c        |   4 +-
>  tc/f_flow.c        |   3 --
>  tc/f_flower.c      |   3 +-
>  tc/f_fw.c          |   6 +--
>  tc/f_route.c       |   3 --
>  tc/f_rsvp.c        |   6 +--
>  tc/f_u32.c         |  12 ++----
>  tc/m_action.c      |  26 ++++---------
>  tc/m_bpf.c         |   5 +--
>  tc/m_csum.c        |   4 +-
>  tc/m_ematch.c      |   4 +-
>  tc/m_gact.c        |   5 +--
>  tc/m_ife.c         |   5 +--
>  tc/m_ipt.c         |  13 ++-----
>  tc/m_mirred.c      |   7 +---
>  tc/m_nat.c         |   4 +-
>  tc/m_pedit.c       |  11 ++----
>  tc/m_police.c      |   5 +--
>  tc/q_atm.c         |   3 +-
>  tc/q_cbq.c         |  22 +++--------
>  tc/q_choke.c       |   4 +-
>  tc/q_codel.c       |   3 +-
>  tc/q_dsmark.c      |   1 -
>  tc/q_fifo.c        |   4 +-
>  tc/q_fq_codel.c    |   3 +-
>  tc/q_hfsc.c        |  13 ++-----
>  tc/q_htb.c         |  15 +++-----
>  tc/q_netem.c       |  16 +++-----
>  tc/q_red.c         |   4 +-
>  tc/q_sfb.c         |  17 ++++-----
>  tc/q_sfq.c         |   4 +-
>  tc/q_tbf.c         |   4 +-
>  tc/tc.c            |   9 ++---
>  tc/tc_bpf.c        |  58 ++++++++++------------------
>  tc/tc_class.c      |  38 +++++++-----------
>  tc/tc_exec.c       |   6 +--
>  tc/tc_filter.c     |  33 ++++++----------
>  tc/tc_qdisc.c      |  33 ++++++----------
>  tc/tc_stab.c       |   4 +-
>  tc/tc_util.c       |   3 +-
>  85 files changed, 565 insertions(+), 977 deletions(-)

I like the idea and it makes code cleaner. But doing this introduces lo=
ts of warnings
and that is not acceptable.
ip
    CC       ip.o
    CC       ipaddress.o
ipaddress.c: In function =E2=80=98print_queuelen=E2=80=99:
ipaddress.c:175:10: warning: missing braces around initializer [-Wmissi=
ng-braces]
   struct ifreq ifr =3D { 0 };
          ^
ipaddress.c:175:10: warning: (near initialization for =E2=80=98ifr.ifr_=
ifrn=E2=80=99) [-Wmissing-braces]
    CC       ipaddrlabel.o
    CC       iproute.o
    CC       iprule.o
    CC       ipnetns.o
    CC       rtm_map.o
    CC       iptunnel.o
iptunnel.c: In function =E2=80=98parse_args=E2=80=99:
iptunnel.c:183:12: warning: missing braces around initializer [-Wmissin=
g-braces]
     struct ip_tunnel_parm old_p =3D { 0 };
            ^
iptunnel.c:183:12: warning: (near initialization for =E2=80=98old_p.nam=
e=E2=80=99) [-Wmissing-braces]
iptunnel.c: In function =E2=80=98print_tunnel=E2=80=99:
iptunnel.c:296:9: warning: missing braces around initializer [-Wmissing=
-braces]
  struct ip_tunnel_6rd ip6rd =3D { 0 };
         ^
iptunnel.c:296:9: warning: (near initialization for =E2=80=98ip6rd.pref=
ix=E2=80=99) [-Wmissing-braces]
iptunnel.c:310:10: warning: missing braces around initializer [-Wmissin=
g-braces]
   struct ip_tunnel_prl prl[16] =3D { 0 };
          ^
iptunnel.c:310:10: warning: (near initialization for =E2=80=98prl[0]=E2=
=80=99) [-Wmissing-braces]
iptunnel.c: In function =E2=80=98do_tunnels_list=E2=80=99:
iptunnel.c:402:10: warning: missing braces around initializer [-Wmissin=
g-braces]
   struct ip_tunnel_parm p1 =3D { 0 };
