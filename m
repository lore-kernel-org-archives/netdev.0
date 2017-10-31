From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 0/3] support changing steering policies in tuntap
Date: Tue, 31 Oct 2017 18:32:15 +0800
Message-ID: <1509445938-4345-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, willemdebruijn.kernel@gmail.com,
        tom@herbertland.com, Jason Wang <jasowang@redhat.com>
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

An example policy was implemented which allows user to load an eBPF to
choose the txq.  Test was done by using xdp_redirect to redirect
traffic generated from MoonGen that was running on a remote
machine. And I see 37% improvement for processor id policy compared to
automatic flow steering policy.

Changes from V1:
- drop processor id example, implement an eBPF based queue selection
  policy instead

Jason Wang (3):
  tun: abstract flow steering logic
  tun: introduce ioctls to set and get steering policies
  tun: add eBPF based queue selection method

 drivers/net/tun.c           | 197 ++++++++++++++++++++++++++++++++++++++------
 include/uapi/linux/if_tun.h |   9 ++
 2 files changed, 183 insertions(+), 23 deletions(-)

-- 
2.7.4
