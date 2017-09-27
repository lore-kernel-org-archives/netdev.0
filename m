From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 0/3] support changing steering policies in tuntap
Date: Wed, 27 Sep 2017 16:23:54 +0800
Message-ID: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

We use flow caches based flow steering policy now. This is good for
connection-oriented communication such as TCP but not for the others
e.g connectionless unidirectional workload which cares only about
pps. This calls the ability of supporting changing steering policies
in tuntap which was done by this series.

Flow steering policy was abstracted into tun_steering_ops in the first
patch. Then new ioctls to set or query current policy were introduced,
and the last patch introduces a very simple policy that select txq
based on processor id as an example.

Test was done by using xdp_redirect to redirect traffic generated from
MoonGen that was running on a remote machine. And I see 37%
improvement for processor id policy compared to automatic flow
steering policy.

In the future, both simple and sophisticated policy like RSS or other guest
driven steering policies could be done on top.

Thanks

Jason Wang (3):
  tun: abstract flow steering logic
  tun: introduce ioctls to set and get steering policies
  tun: introduce cpu id based steering policy

 drivers/net/tun.c           | 151 +++++++++++++++++++++++++++++++++++++-------
 include/uapi/linux/if_tun.h |   8 +++
 2 files changed, 136 insertions(+), 23 deletions(-)

-- 
2.7.4
