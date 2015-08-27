From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next 0/2] OPENVSWITCH && !NETFILTER build fix.
Date: Thu, 27 Aug 2015 15:25:44 -0700
Message-ID: <1440714346-43304-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pshelar@nicira.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix issues reported by kbuild test robot:

All error/warnings (new ones prefixed by >>):

   net/openvswitch/actions.c: In function 'ovs_fragment':
>> net/openvswitch/actions.c:705:16: error: implicit declaration of
function 'nf_get_ipv6_ops' [-Werror=implicit-function-declaration]
      const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
                   ^
>> net/openvswitch/actions.c:705:37: warning: initialization makes
pointer from integer without a cast
      const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
                                        ^
>> net/openvswitch/actions.c:707:19: error: storage size of 'ovs_rt'
isn't known
      struct rt6_info ovs_rt;
                      ^
>> net/openvswitch/actions.c:724:8: error: dereferencing pointer to
incomplete type
      v6ops->fragment(skb->sk, skb, ovs_vport_output);
           ^
>> net/openvswitch/actions.c:707:19: warning: unused variable 'ovs_rt'
[-Wunused-variable]
      struct rt6_info ovs_rt;
                      ^
   cc1: some warnings being treated as errors

Joe Stringer (2):
  netfilter: Define v6ops in !CONFIG_NETFILTER case.
  openvswitch: Include ip6_fib.h.

 include/linux/netfilter_ipv6.h | 18 +++++++++---------
 net/openvswitch/actions.c      |  1 +
 2 files changed, 10 insertions(+), 9 deletions(-)

-- 
2.1.4
