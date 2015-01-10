From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] netfilter/ipvs fixes for net
Date: Sat, 10 Jan 2015 19:50:02 +0100
Message-ID: <1420915808-7160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains netfilter/ipvs fixes, they are:

1) Small fix for the FTP helper in IPVS, a diff variable may be left
   unset when CONFIG_IP_VS_IPV6 is set. Patch from Dan Carpenter.

2) Fix nf_tables port NAT in little endian archs, patch from leroy
   christophe.

3) Fix race condition between conntrack confirmation and flush from
   userspace. This is the second reincarnation to resolve this problem.

4) Make sure inner messages in the batch come with the nfnetlink header.

5) Relax strict check from nfnetlink_bind() that may break old userspace
   applications using all 1s group mask.

6) Schedule removal of chains once no sets and rules refer to them in
   the new nf_tables ruleset flush command. Reported by Asbjoern Sloth
   Toennesen.

Note that this batch comes later than usual because of the short
winter holidays.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Have a happy new year, thanks!

----------------------------------------------------------------

The following changes since commit ac9a3d84e121196263636f2d38d439a45888005a:

  be2net: Fix incorrect setting of tunnel offload flag in netdev features (2014-12-18 12:51:29 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to a2f18db0c68fec96631c10cad9384c196e9008ac:

  netfilter: nf_tables: fix flush ruleset chain dependencies (2015-01-06 22:27:48 +0100)

----------------------------------------------------------------
Dan Carpenter (1):
      ipvs: uninitialized data with IP_VS_IPV6

Pablo Neira Ayuso (5):
      Merge tag 'ipvs2-for-v3.19' of https://git.kernel.org/.../horms/ipvs-next into ipvs-next
      netfilter: conntrack: fix race between confirmation and flush
      netfilter: nfnetlink: validate nfnetlink header from batch
      netfilter: nfnetlink: relax strict multicast group check from netlink_bind
      netfilter: nf_tables: fix flush ruleset chain dependencies

leroy christophe (1):
      netfilter: nf_tables: fix port natting in little endian archs

 net/ipv4/netfilter/nft_redir_ipv4.c |    8 ++++----
 net/ipv6/netfilter/nft_redir_ipv6.c |    8 ++++----
 net/netfilter/ipvs/ip_vs_ftp.c      |   10 +++++-----
 net/netfilter/nf_conntrack_core.c   |   20 +++++++++-----------
 net/netfilter/nf_tables_api.c       |   14 +++++++++-----
 net/netfilter/nfnetlink.c           |    5 +++--
 net/netfilter/nft_nat.c             |    8 ++++----
 7 files changed, 38 insertions(+), 35 deletions(-)

