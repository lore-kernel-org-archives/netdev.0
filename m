From: Nikolay Borisov <kernel@kyup.com>
Subject: [RESEND PATCH 0/9] Namespaceify more of the tcp sysctl knobs
Date: Wed,  3 Feb 2016 09:46:48 +0200
Message-ID: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Cc: edumazet@google.com, ebiederm@xmission.com, fan.du@intel.com,
	kaber@trash.net, jmorris@namei.org, alexander.h.duyck@redhat.com,
	kuznet@ms2.inr.ac.ru
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series continues making more of the tcp-related
sysctl knobs be per net-namespace. Most of these apply per
socket and have global defaults so should be safe and I
don't expect any breakages. 

Having those per net-namespace is useful when multiple  
containers are hosted and it is required to tune the 
tcp settings for each independently of the host node. 

I've split the patches to be per-sysctl but after
the review if the outcome is positive I'm happy
to either send it in one big blob or just.  

Nikolay Borisov (9):
  ipv4: Namespaceify tcp syn retries sysctl knob
  ipv4: Namespaceify tcp synack retries sysctl knob
  ipv4: Namespaceify tcp syncookies sysctl knob
  ipv4: Namespaceify tcp reordering sysctl knob
  ipv4: Namespaceify tcp_retries1 sysctl knob
  ipv4: Namespaceify tcp_retries2 sysctl knob
  ipv4: Namespaceify tcp_orphan_retries sysctl knob
  ipv4: Namespaceify tcp_fin_timeout sysctl knob
  ipv4: Namespaceify tcp_notsent_lowat sysctl knob

 include/net/netns/ipv4.h        |  10 +++
 include/net/tcp.h               |  17 ++---
 net/ipv4/inet_connection_sock.c |   7 +--
 net/ipv4/syncookies.c           |   4 +-
 net/ipv4/sysctl_net_ipv4.c      | 136 ++++++++++++++++++++--------------------
 net/ipv4/tcp.c                  |  12 ++--
 net/ipv4/tcp_input.c            |  22 ++++---
 net/ipv4/tcp_ipv4.c             |  11 +++-
 net/ipv4/tcp_metrics.c          |   3 +-
 net/ipv4/tcp_minisocks.c        |   3 -
 net/ipv4/tcp_output.c           |   6 +-
 net/ipv4/tcp_timer.c            |  23 +++----
 net/ipv6/syncookies.c           |   2 +-
 13 files changed, 130 insertions(+), 126 deletions(-)

-- 
2.5.0
