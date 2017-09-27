From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next 2/2] net/sched: allow flower to match tunnel
 options
Date: Wed, 27 Sep 2017 11:10:05 +0200
Message-ID: <20170927091005.GB1944@nanopsycho.orion>
References: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
 <1506500194-17637-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:43228 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752611AbdI0JKH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 05:10:07 -0400
Received: by mail-wm0-f66.google.com with SMTP id m72so19281265wmc.0
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 02:10:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1506500194-17637-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 27, 2017 at 10:16:34AM CEST, simon.horman@netronome.com wrote:
>Allow matching on options in tunnel headers.
>This makes use of existing tunnel metadata support.
>
>Options are a bytestring of up to 256 bytes.
>Tunnel implementations may support less or more options,
>or no options at all.
>
>e.g.
> # ip link add name geneve0 type geneve dstport 0 external
> # tc qdisc add dev geneve0 ingress
> # tc filter add dev geneve0 protocol ip parent ffff: \
>     flower \
>       enc_src_ip 10.0.99.192 \
>       enc_dst_ip 10.0.99.193 \
>       enc_key_id 11 \
>       enc_opts 0102800100800020/fffffffffffffff0 \
>       ip_proto udp \
>       action mirred egress redirect dev eth1
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>
>Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>
>---
>v2
>* Correct example which was incorrectly described setting rather
>  than matching tunnel options
>---
> include/net/flow_dissector.h | 13 +++++++++++++
> include/uapi/linux/pkt_cls.h |  3 +++
> net/sched/cls_flower.c       | 35 ++++++++++++++++++++++++++++++++++-
> 3 files changed, 50 insertions(+), 1 deletion(-)
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index fc3dce730a6b..43f98bf0b349 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -183,6 +183,18 @@ struct flow_dissector_key_ip {
> 	__u8	ttl;
> };
> 
>+/**
>+ * struct flow_dissector_key_enc_opts:
>+ * @data: data
>+ * @len: len
>+ */
>+struct flow_dissector_key_enc_opts {
>+	u8 data[256];	/* Using IP_TUNNEL_OPTS_MAX is desired here
>+			 * but seems difficult to #include
>+			 */
>+	u8 len;
>+};
>+
> enum flow_dissector_key_id {
> 	FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
> 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
>@@ -205,6 +217,7 @@ enum flow_dissector_key_id {
> 	FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
> 	FLOW_DISSECTOR_KEY_TCP, /* struct flow_dissector_key_tcp */
> 	FLOW_DISSECTOR_KEY_IP, /* struct flow_dissector_key_ip */
>+	FLOW_DISSECTOR_KEY_ENC_OPTS, /* struct flow_dissector_key_enc_opts */

I don't see the actual dissection implementation. Where is it?
Did you test the patchset?
