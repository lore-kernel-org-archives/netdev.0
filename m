From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH RFC] flow_dissector: Add FLOW_DISSECTOR_F_FLOWER
Date: Mon, 2 Oct 2017 16:49:46 +0200
Message-ID: <20171002144946.GE1941@nanopsycho.orion>
References: <20170929191343.11318-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hannes@stressinduktion.org,
        netdev@vger.kernel.org, rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:43703 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdJBOts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 10:49:48 -0400
Received: by mail-wm0-f68.google.com with SMTP id m72so7790125wmc.0
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 07:49:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170929191343.11318-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 29, 2017 at 09:13:42PM CEST, tom@quantonium.net wrote:
>This patch is RFC and would be applied after "flow_dissector:
>Protocol specific flow dissector offload"
>
>In order to maitain uAPI in flower, the FLOW_DISSECTOR_F_FLOWER flag
>is added to indicate to flow_dissector that the caller is flower.
>As new funtionality is addes to flow_dissector that would break
>the flower uAPI, the code can be wrapped in "if (!(flags &
>FLOW_DISSECTOR_F_FLOWER)).
>
>In this patch the conditional is use around protocol specific
>dissection (e.g. DPI into VXLAN) as well as the code that
>enforces a depth of parsing to prevent DPI. The latter was a
>recent patch that would introduce a parsing limit to flower that
>did not exist before (i.e. would break uAPI).
>
>Signed-off-by: Tom Herbert <tom@quantonium.net>
>---
> include/net/flow_dissector.h |  1 +
> net/core/flow_dissector.c    | 17 +++++++++++------
> net/sched/cls_flow.c         |  3 ++-
> 3 files changed, 14 insertions(+), 7 deletions(-)
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index ad75bbfd1c9c..ca315107d147 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -214,6 +214,7 @@ enum flow_dissector_key_id {
> #define FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL	BIT(2)
> #define FLOW_DISSECTOR_F_STOP_AT_ENCAP		BIT(3)
> #define FLOW_DISSECTOR_F_STOP_AT_L4		BIT(4)
>+#define FLOW_DISSECTOR_F_FLOWER			BIT(5)

I don't like flow_dissector to have any user-specific bits. Note that
the same dissection may be used not only from flower, but from other
code as well (OVS). Flow dissector should not care who the caller is.
