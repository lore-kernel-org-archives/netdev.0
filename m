From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next 10/13] openvswitch: add support for
 datapath hardware offload
Date: Thu, 4 Sep 2014 14:48:37 +0200
Message-ID: <20140904124837.GI1867@nanopsycho.lan>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-11-git-send-email-jiri@resnulli.us>
 <540743B4.9080500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <540743B4.9080500-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Wed, Sep 03, 2014 at 06:37:08PM CEST, john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>On 09/03/2014 02:24 AM, Jiri Pirko wrote:
>>Benefit from the possibility to work with flows in switch devices and
>>use the swdev api to offload flow datapath.
>>
>>Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>>---
>>  net/openvswitch/Makefile       |   3 +-
>>  net/openvswitch/datapath.c     |  33 ++++++
>>  net/openvswitch/datapath.h     |   3 +
>>  net/openvswitch/flow_table.c   |   1 +
>>  net/openvswitch/hw_offload.c   | 245 +++++++++++++++++++++++++++++++++++++++++
>>  net/openvswitch/hw_offload.h   |  22 ++++
>>  net/openvswitch/vport-netdev.c |   3 +
>>  net/openvswitch/vport.h        |   2 +
>>  8 files changed, 311 insertions(+), 1 deletion(-)
>>  create mode 100644 net/openvswitch/hw_offload.c
>>  create mode 100644 net/openvswitch/hw_offload.h
>>
>>diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
>>index 3591cb5..5152437 100644
>>--- a/net/openvswitch/Makefile
>>+++ b/net/openvswitch/Makefile
>>@@ -13,7 +13,8 @@ openvswitch-y := \
>>  	flow_table.o \
>>  	vport.o \
>>  	vport-internal_dev.o \
>>-	vport-netdev.o
>>+	vport-netdev.o \
>>+	hw_offload.o
>>
>>  ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
>>  openvswitch-y += vport-vxlan.o
>>diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
>>index 75bb07f..3e43e1d 100644
>>--- a/net/openvswitch/datapath.c
>>+++ b/net/openvswitch/datapath.c
>>@@ -57,6 +57,7 @@
>>  #include "flow_netlink.h"
>>  #include "vport-internal_dev.h"
>>  #include "vport-netdev.h"
>>+#include "hw_offload.h"
>>
>>  int ovs_net_id __read_mostly;
>>
>>@@ -864,6 +865,9 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>>  			acts = NULL;
>>  			goto err_unlock_ovs;
>>  		}
>>+		error = ovs_hw_flow_insert(dp, new_flow);
>>+		if (error)
>>+			pr_warn("failed to insert flow into hw\n");
>
>This is really close to silently failing. I think we need to
>hard fail here somehow and push it back to userspace as part of
>the reply and ovs_notify.

Yes, I agree. My plan was to handle this in ovs hw/sw/both netlink attr
implementation.


>
>Otherwise I don't know how to manage the hardware correctly. Consider
>the hardware table is full. In this case user space will continue to
>add rules and they will be silently discarded. Similarly if user space
>adds a flow/action that can not be supported by the hardware it will
>be silently ignored.
>
>Even if we do careful accounting on resources in user space we could
>still get an ENOMEM error from sw_flow_action_create.
>
>Same comment for the other hw commands flush/remove.
>
>>  		if (unlikely(reply)) {
>>  			error = ovs_flow_cmd_fill_info(new_flow,
>>@@ -896,10 +900,18 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>>  				goto err_unlock_ovs;
>>  			}
>>  		}
>
>
>[...]
>
>
>Thanks,
>John
>
>-- 
>John Fastabend         Intel Corporation
