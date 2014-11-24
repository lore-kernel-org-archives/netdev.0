From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc_vlan: fix type of tcfv_push_vid
Date: Mon, 24 Nov 2014 14:33:00 +0100
Message-ID: <20141124133300.GB7225@nanopsycho.orion>
References: <1416825026-4628-1-git-send-email-jiri@resnulli.us>
 <547331E0.6030305@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:58353 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaKXNdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 08:33:04 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so5786599wiv.8
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 05:33:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547331E0.6030305@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 24, 2014 at 02:25:52PM CET, jhs@mojatatu.com wrote:
>On 11/24/14 05:30, Jiri Pirko wrote:
>>Should be u16. So fix it to kill the sparse warning.
>>
>>Fixes: c7e2b9689ef8136 "sched: introduce vlan action"
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  include/net/tc_act/tc_vlan.h | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>>diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
>>index c809c1d..93b70ad 100644
>>--- a/include/net/tc_act/tc_vlan.h
>>+++ b/include/net/tc_act/tc_vlan.h
>>@@ -18,7 +18,7 @@
>>  struct tcf_vlan {
>>  	struct tcf_common	common;
>>  	int			tcfv_action;
>>-	__be16			tcfv_push_vid;
>>+	u16			tcfv_push_vid;
>>  	__be16			tcfv_push_proto;
>
>
>User space sends you this in be, no? I thought it was fine
>the way it is. Isnt __be16 just an annotation?

No, userspace sends this in host. Therefore we should store it in host,
not in be. It is just an annotation.

>
>cheers,
>jamal
>
