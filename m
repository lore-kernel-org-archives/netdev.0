From: Andy Zhou <azhou@nicira.com>
Subject: [datapath minor fixes 3/3] datapath: serializing GENEVE options based on flow key's tun_flags
Date: Wed,  1 Oct 2014 00:55:48 -0700
Message-ID: <1412150148-9991-4-git-send-email-azhou@nicira.com>
References: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:59928 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750981AbaJAHy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 03:54:59 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so316702pdj.4
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 00:54:59 -0700 (PDT)
In-Reply-To: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TUNNEL_OPTIONS_PRESENT should always be checked against the tun_flgs
bits in a flow key, for both flow and mask serialization.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 datapath/flow_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
index a3f34f1..35feedc 100644
--- a/datapath/flow_netlink.c
+++ b/datapath/flow_netlink.c
@@ -1122,7 +1122,7 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 	if ((swkey->tun_key.ipv4_dst || is_mask)) {
 		const struct geneve_opt *opts = NULL;
 
-		if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
+		if (swkey->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
 			opts = GENEVE_OPTS(output, swkey->tun_opts_len);
 
 		if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
-- 
1.9.1
