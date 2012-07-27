From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] team: add signed 32-bit team option type
Date: Fri, 27 Jul 2012 18:28:53 +0200
Message-ID: <1343406535-22388-3-git-send-email-jiri@resnulli.us>
References: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45277 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab2G0Q3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 12:29:05 -0400
Received: by wgbdr13 with SMTP id dr13so2963822wgb.1
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 09:29:03 -0700 (PDT)
In-Reply-To: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c |   12 ++++++++++++
 include/linux/if_team.h |    2 ++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 87707ab..70752e6 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1787,6 +1787,12 @@ static int team_nl_fill_one_option_get(struct sk_buff *skb, struct team *team,
 		    nla_put_flag(skb, TEAM_ATTR_OPTION_DATA))
 			goto nest_cancel;
 		break;
+	case TEAM_OPTION_TYPE_S32:
+		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_S32))
+			goto nest_cancel;
+		if (nla_put_s32(skb, TEAM_ATTR_OPTION_DATA, ctx.data.s32_val))
+			goto nest_cancel;
+		break;
 	default:
 		BUG();
 	}
@@ -1975,6 +1981,9 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 		case NLA_FLAG:
 			opt_type = TEAM_OPTION_TYPE_BOOL;
 			break;
+		case NLA_S32:
+			opt_type = TEAM_OPTION_TYPE_S32;
+			break;
 		default:
 			goto team_put;
 		}
@@ -2031,6 +2040,9 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 			case TEAM_OPTION_TYPE_BOOL:
 				ctx.data.bool_val = attr_data ? true : false;
 				break;
+			case TEAM_OPTION_TYPE_S32:
+				ctx.data.s32_val = nla_get_s32(attr_data);
+				break;
 			default:
 				BUG();
 			}
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 6960fc1..e5571c4 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -130,6 +130,7 @@ enum team_option_type {
 	TEAM_OPTION_TYPE_STRING,
 	TEAM_OPTION_TYPE_BINARY,
 	TEAM_OPTION_TYPE_BOOL,
+	TEAM_OPTION_TYPE_S32,
 };
 
 struct team_option_inst_info {
@@ -146,6 +147,7 @@ struct team_gsetter_ctx {
 			u32 len;
 		} bin_val;
 		bool bool_val;
+		s32 s32_val;
 	} data;
 	struct team_option_inst_info *info;
 };
-- 
1.7.10.4
