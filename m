From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: ipv6: Failure to disable forwarding per interface
 via sysctl
Date: Fri, 16 Sep 2016 13:38:33 +0200
Message-ID: <20160916113833.GA2209@nanopsycho.orion>
References: <1474019290-17626-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34576 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760629AbcIPLil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 07:38:41 -0400
Received: by mail-wm0-f67.google.com with SMTP id l132so2147652wmf.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 04:38:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474019290-17626-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 16, 2016 at 11:48:10AM CEST, mmanning@brocade.com wrote:
>Disabling forwarding per interface via sysctl continues to allow
>forwarding. This is contrary to the sysctl documentation stating that
>the forwarding sysctl is per interface, whereas currently it is only
>the sysctl for all interfaces that has an effect on forwarding. The
>solution is to drop any received packets instead of forwarding them
>if the ingress device has a per-device forwarding sysctl that is unset.
>
>Signed-off-by: Mike Manning <mmanning@brocade.com>

The patch looks fine. But the subject is a bit weird:
Subject: [PATCH] net: ipv6: Failure to disable forwarding per interface
via sysctl

In subject of the patch you should say what the patch does.


>---
> net/ipv6/ip6_output.c |    4 ++++
> 1 file changed, 4 insertions(+)
>
>diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>index 1dfc402..37cd1d0 100644
>--- a/net/ipv6/ip6_output.c
>+++ b/net/ipv6/ip6_output.c
>@@ -380,11 +380,15 @@ int ip6_forward(struct sk_buff *skb)
> 	struct ipv6hdr *hdr = ipv6_hdr(skb);
> 	struct inet6_skb_parm *opt = IP6CB(skb);
> 	struct net *net = dev_net(dst->dev);
>+	struct inet6_dev *idev = __in6_dev_get(skb->dev);
> 	u32 mtu;
> 
> 	if (net->ipv6.devconf_all->forwarding == 0)
> 		goto error;
> 
>+	if (idev && !idev->cnf.forwarding)
>+		goto error;
>+
> 	if (skb->pkt_type != PACKET_HOST)
> 		goto drop;
> 
>-- 
>1.7.10.4
>
