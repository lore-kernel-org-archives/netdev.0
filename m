From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v4 2/5] Use C99 style initializers everywhere
Date: Fri, 15 Jul 2016 09:33:24 -0600
Message-ID: <2cd2d490-addc-e864-bce9-4526b409b908@cumulusnetworks.com>
References: <1468435639-6892-1-git-send-email-phil@nwl.cc>
 <1468435639-6892-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37574 "EHLO
	mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcGOPd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 11:33:26 -0400
Received: by mail-it0-f49.google.com with SMTP id f6so22102781ith.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 08:33:25 -0700 (PDT)
In-Reply-To: <1468435639-6892-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/16 12:47 PM, Phil Sutter wrote:
> This big patch was compiled by vimgrepping for memset calls and changing
> to C99 initializer if applicable. One notable exception is the
> initialization of union bpf_attr in tc/tc_bpf.c: changing it would break
> for older gcc versions (at least <=3.4.6).
>
> Calls to memset for struct rtattr pointer fields for parse_rtattr*()
> were just dropped since they are not needed.
>
> The changes here allowed the compiler to discover some unused variables,
> so get rid of them, too.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v3:
> - Use empty instead of zero initializer.
> Changes since v2:
> - Flatten initializers.
> - Leave a final comma in place.
> - Fix checkpatch warnings.
> - Initialize nlmsg_seq in the declaration, too.
> - Use C99-style init in tc_bpf.c to get rid of the memset().
> Changes since v1:
> - Dropped former changes to tc/tc_bpf.c as they are incompatible to older
>   gcc versions (at least <=3.4.6).
> ---
>  bridge/fdb.c     |  25 ++++++-------
>  bridge/link.c    |  14 +++----
>  bridge/mdb.c     |  17 ++++-----
>  bridge/vlan.c    |  17 ++++-----
>  genl/ctrl.c      |  44 +++++++++-------------
>  ip/ip6tunnel.c   |  10 ++---
>  ip/ipaddress.c   |  31 +++++++---------
>  ip/ipaddrlabel.c |  21 ++++-------
>  ip/iplink.c      |  61 +++++++++++++-----------------
>  ip/iplink_can.c  |   4 +-
>  ip/ipmaddr.c     |  25 ++++---------
>  ip/ipmroute.c    |   8 +---
>  ip/ipneigh.c     |  30 ++++++---------
>  ip/ipnetconf.c   |  10 ++---
>  ip/ipnetns.c     |  39 +++++++++-----------
>  ip/ipntable.c    |  25 ++++---------
>  ip/iproute.c     |  78 ++++++++++++++-------------------------
>  ip/iprule.c      |  22 +++++------
>  ip/iptoken.c     |  19 ++++------
>  ip/iptunnel.c    |  31 +++++-----------
>  ip/ipxfrm.c      |  26 ++++---------
>  ip/link_gre.c    |  18 ++++-----
>  ip/link_gre6.c   |  18 ++++-----
>  ip/link_ip6tnl.c |  25 +++++--------
>  ip/link_iptnl.c  |  22 +++++------
>  ip/link_vti.c    |  18 ++++-----
>  ip/link_vti6.c   |  18 ++++-----
>  ip/xfrm_policy.c |  99 ++++++++++++++++++++-----------------------------
>  ip/xfrm_state.c  | 110 +++++++++++++++++++++++--------------------------------
>  lib/libnetlink.c |  77 ++++++++++++++------------------------
>  lib/ll_map.c     |   1 -
>  misc/arpd.c      |  64 ++++++++++++++------------------
>  misc/ss.c        |  37 +++++++------------
>  tc/e_bpf.c       |   7 +---
>  tc/em_cmp.c      |   4 +-
>  tc/em_ipset.c    |   4 +-
>  tc/em_meta.c     |   4 +-
>  tc/em_nbyte.c    |   4 +-
>  tc/em_u32.c      |   4 +-
>  tc/f_flow.c      |   3 --
>  tc/f_flower.c    |   3 +-
>  tc/f_fw.c        |   6 +--
>  tc/f_route.c     |   3 --
>  tc/f_rsvp.c      |   6 +--
>  tc/f_u32.c       |  12 ++----
>  tc/m_bpf.c       |   5 +--
>  tc/m_csum.c      |   4 +-
>  tc/m_ematch.c    |   4 +-
>  tc/m_gact.c      |   5 +--
>  tc/m_ife.c       |   5 +--
>  tc/m_mirred.c    |   7 +---
>  tc/m_nat.c       |   4 +-
>  tc/m_pedit.c     |   8 +---
>  tc/m_police.c    |   5 +--
>  tc/q_atm.c       |   3 +-
>  tc/q_cbq.c       |  22 +++--------
>  tc/q_choke.c     |   4 +-
>  tc/q_codel.c     |   3 +-
>  tc/q_dsmark.c    |   1 -
>  tc/q_fifo.c      |   4 +-
>  tc/q_fq_codel.c  |   3 +-
>  tc/q_hfsc.c      |  13 ++-----
>  tc/q_htb.c       |  15 +++-----
>  tc/q_netem.c     |  16 +++-----
>  tc/q_red.c       |   4 +-
>  tc/q_sfb.c       |  17 ++++-----
>  tc/q_sfq.c       |   4 +-
>  tc/q_tbf.c       |   4 +-
>  tc/tc_bpf.c      |  54 ++++++++++-----------------
>  tc/tc_class.c    |  31 ++++++----------
>  tc/tc_exec.c     |   3 +-
>  tc/tc_filter.c   |  33 ++++++-----------
>  tc/tc_qdisc.c    |  33 ++++++-----------
>  tc/tc_stab.c     |   4 +-
>  tc/tc_util.c     |   3 +-
>  75 files changed, 532 insertions(+), 913 deletions(-)


Really good cleanup. Thanks for taking the time to do it.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
