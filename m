From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2/net-next] tc: add support for TRAP action
Date: Thu, 8 Jun 2017 08:57:19 +0200
Message-ID: <20170608065719.GD2238@nanopsycho>
References: <20170605143832.7025-1-jiri@resnulli.us>
 <20170605143945.7094-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34864 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdFHG5X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:57:23 -0400
Received: by mail-wr0-f194.google.com with SMTP id g76so2926265wrd.2
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:57:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170605143945.7094-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 05, 2017 at 04:39:45PM CEST, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Stephen, note that the kernel part was accepted in v2. Thanks.


>---
> include/linux/pkt_cls.h | 5 +++++
> tc/tc_util.c            | 3 +++
> 2 files changed, 8 insertions(+)
>
>diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
>index c6e8cf5..477ed05 100644
>--- a/include/linux/pkt_cls.h
>+++ b/include/linux/pkt_cls.h
>@@ -37,6 +37,11 @@ enum {
> #define TC_ACT_QUEUED		5
> #define TC_ACT_REPEAT		6
> #define TC_ACT_REDIRECT		7
>+#define TC_ACT_TRAP		8 /* For hw path, this means "trap to cpu",
>+				   * for sw path, this is equivalent of
>+				   * TC_ACT_STOLEN - drop the skb and act
>+				   * like everything is allright.
>+				   */
> 
> /* There is a special kind of actions called "extended actions",
>  * which need a value parameter. These have a local opcode located in
>diff --git a/tc/tc_util.c b/tc/tc_util.c
>index 4f7283d..5a0f96a 100644
>--- a/tc/tc_util.c
>+++ b/tc/tc_util.c
>@@ -430,6 +430,8 @@ static const char *action_n2a(int action)
> 		return "pipe";
> 	case TC_ACT_STOLEN:
> 		return "stolen";
>+	case TC_ACT_TRAP:
>+		return "trap";
> 	default:
> 		snprintf(buf, 64, "%d", action);
> 		buf[63] = '\0';
>@@ -462,6 +464,7 @@ static int action_a2n(char *arg, int *result, bool allow_num)
> 		{"reclassify", TC_ACT_RECLASSIFY},
> 		{"pipe", TC_ACT_PIPE},
> 		{"goto", TC_ACT_GOTO_CHAIN},
>+		{"trap", TC_ACT_TRAP},
> 		{ NULL },
> 	}, *iter;
> 
>-- 
>2.9.3
>
