From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 0/6] net: add skb_to_full_sk() helper
Date: Sun,  8 Nov 2015 10:54:06 -0800
Message-ID: <1447008853-16060-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paul Moore <paul@paul-moore.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36702 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbKHSyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 13:54:20 -0500
Received: by pacdm15 with SMTP id dm15so150496504pac.3
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 10:54:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many contexts need to reach listener socket from skb attached
to a request socket. This patch series add skb_to_full_sk() to
clearly express this need and use it where appropriate.

Eric Dumazet (6):
  net: add skb_to_full_sk() helper and use it in
    selinux_netlbl_skbuff_setsid()
  smack: use skb_to_full_sk() helper
  netfilter: xt_owner: use skb_to_full_sk() helper
  sched: cls_flow: use skb_to_full_sk() helper
  net_sched: em_meta: use skb_to_full_sk() helper
  netfilter: nft_meta: use skb_to_full_sk() helper

 include/net/inet_sock.h          |  12 ++++
 net/netfilter/nft_meta.c         |  36 +++++-----
 net/netfilter/xt_owner.c         |   6 +-
 net/sched/cls_flow.c             |  15 +++--
 net/sched/em_meta.c              | 138 ++++++++++++++++++++++++++-------------
 security/selinux/hooks.c         |  16 +----
 security/selinux/netlabel.c      |   2 +-
 security/smack/smack_netfilter.c |  11 ++--
 8 files changed, 149 insertions(+), 87 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
