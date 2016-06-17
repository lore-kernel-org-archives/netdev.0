From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 18:09:20 +0200
Message-ID: <576420B0.3050203@iogearbox.net>
References: <1466178968-27439-1-git-send-email-phil@nwl.cc> <1466178968-27439-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58707 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbcFQQJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:09:29 -0400
In-Reply-To: <1466178968-27439-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2016 05:56 PM, Phil Sutter wrote:
> This big patch was compiled by vimgrepping for memset calls and changing
> to C99 initializer if applicable.
>
> Calls to memset for struct rtattr pointer fields for parse_rtattr*()
> were just dropped since they are not needed.
>
> The changes here allowed the compiler to discover some unused variables,
> so get rid of them, too.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>   bridge/fdb.c     |  29 +++++++------
>   bridge/link.c    |  16 +++----
>   bridge/mdb.c     |  19 ++++-----
>   bridge/vlan.c    |  19 ++++-----
>   genl/ctrl.c      |  48 +++++++++------------
>   ip/ip6tunnel.c   |  10 ++---
>   ip/ipaddress.c   |  31 ++++++--------
>   ip/ipaddrlabel.c |  23 +++++-----
>   ip/iplink.c      |  67 ++++++++++++++---------------
>   ip/iplink_can.c  |   4 +-
>   ip/ipmaddr.c     |  27 +++++-------
>   ip/ipmroute.c    |   8 +---
>   ip/ipneigh.c     |  36 ++++++++--------
>   ip/ipnetconf.c   |  12 +++---
>   ip/ipnetns.c     |  45 ++++++++++---------
>   ip/ipntable.c    |  27 +++++-------
>   ip/iproute.c     |  85 ++++++++++++++++--------------------
>   ip/iprule.c      |  26 +++++------
>   ip/iptoken.c     |  21 ++++-----
>   ip/iptunnel.c    |  31 ++++----------
>   ip/ipxfrm.c      |  26 +++--------
>   ip/link_gre.c    |  22 +++++-----
>   ip/link_gre6.c   |  22 +++++-----
>   ip/link_ip6tnl.c |  29 ++++++-------
>   ip/link_iptnl.c  |  26 +++++------
>   ip/link_vti.c    |  22 +++++-----
>   ip/link_vti6.c   |  22 +++++-----
>   ip/xfrm_policy.c | 110 ++++++++++++++++++++++-------------------------
>   ip/xfrm_state.c  | 128 +++++++++++++++++++++++++++----------------------------
>   lib/libnetlink.c |  74 ++++++++++++++------------------
>   lib/ll_map.c     |   1 -
>   misc/arpd.c      |  68 ++++++++++++++---------------
>   misc/ss.c        |  41 ++++++++----------
>   tc/e_bpf.c       |   7 +--
>   tc/em_cmp.c      |   4 +-
>   tc/em_ipset.c    |   4 +-
>   tc/em_meta.c     |   4 +-
>   tc/em_nbyte.c    |   4 +-
>   tc/em_u32.c      |   4 +-
>   tc/f_flow.c      |   3 --
>   tc/f_flower.c    |   3 +-
>   tc/f_fw.c        |   6 +--
>   tc/f_route.c     |   3 --
>   tc/f_rsvp.c      |   6 +--
>   tc/f_u32.c       |  12 ++----
>   tc/m_action.c    |  51 +++++++++-------------
>   tc/m_bpf.c       |   5 +--
>   tc/m_csum.c      |   4 +-
>   tc/m_ematch.c    |   4 +-
>   tc/m_gact.c      |   5 +--
>   tc/m_ife.c       |   5 +--
>   tc/m_mirred.c    |   7 +--
>   tc/m_nat.c       |   4 +-
>   tc/m_pedit.c     |   8 +---
>   tc/m_police.c    |   5 +--
>   tc/q_atm.c       |   3 +-
>   tc/q_cbq.c       |  22 +++-------
>   tc/q_choke.c     |   4 +-
>   tc/q_codel.c     |   3 +-
>   tc/q_dsmark.c    |   1 -
>   tc/q_fifo.c      |   4 +-
>   tc/q_fq_codel.c  |   3 +-
>   tc/q_hfsc.c      |  13 ++----
>   tc/q_htb.c       |  15 +++----
>   tc/q_netem.c     |  16 +++----
>   tc/q_red.c       |   4 +-
>   tc/q_sfb.c       |  17 ++++----
>   tc/q_sfq.c       |   4 +-
>   tc/q_tbf.c       |   4 +-
>   tc/tc_bpf.c      |  96 +++++++++++++++++------------------------
>   tc/tc_class.c    |  33 ++++++--------
>   tc/tc_exec.c     |   3 +-
>   tc/tc_filter.c   |  35 ++++++---------
>   tc/tc_qdisc.c    |  35 ++++++---------
>   tc/tc_stab.c     |   4 +-
>   tc/tc_util.c     |   3 +-
>   76 files changed, 699 insertions(+), 956 deletions(-)
[...]

Hmm, seems like a lot of stuff ...

[...]
> diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
> index 86c6069b68ec4..8a264531dcdd4 100644
> --- a/tc/tc_bpf.c
> +++ b/tc/tc_bpf.c
> @@ -86,13 +86,12 @@ static int bpf(int cmd, union bpf_attr *attr, unsigned int size)
>   static int bpf_map_update(int fd, const void *key, const void *value,
>   			  uint64_t flags)
>   {
> -	union bpf_attr attr;
> -
> -	memset(&attr, 0, sizeof(attr));
> -	attr.map_fd = fd;
> -	attr.key = bpf_ptr_to_u64(key);
> -	attr.value = bpf_ptr_to_u64(value);
> -	attr.flags = flags;
> +	union bpf_attr attr = {
> +		.map_fd = fd,
> +		.key = bpf_ptr_to_u64(key),
> +		.value = bpf_ptr_to_u64(value),
> +		.flags = flags
> +	};
>
>   	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
[...]

Please have a look at commit 8f80d450c3cb ("tc: fix compilation with old gcc (< 4.6)") ...

Your changes effectively revert them again. Here, and some other parts of the bpf frontend
code bits.

Thanks,
Daniel
