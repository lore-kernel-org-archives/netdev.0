From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
 get/set operations
Date: Mon, 23 Oct 2017 10:05:34 -0400
Message-ID: <CA+Jmh7E2N1fhW_b9NRbFYcfnupzBcWsjR98E=8BM1qusR=TpXA@mail.gmail.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com>
 <20171020143948.GC1994@nanopsycho.orion> <CA+Jmh7GptV5EZYWpQzHnT8Q1KDSZ-juQCfOr=VKFt4jyMOqFYw@mail.gmail.com>
 <20171021092421.GB1948@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:52741 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdJWOFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 10:05:55 -0400
Received: by mail-qt0-f196.google.com with SMTP id 31so26222647qtz.9
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 07:05:55 -0700 (PDT)
In-Reply-To: <20171021092421.GB1948@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 21, 2017 at 5:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Oct 20, 2017 at 05:13:39PM CEST, steven.lin1@broadcom.com wrote:
>>On Fri, Oct 20, 2017 at 10:39 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, Oct 19, 2017 at 09:17:05PM CEST, steven.lin1@broadcom.com wrote:
>>>>Add support for permanent config parameter get/set commands. Used
>>>>for parameters held in NVRAM, persistent device configuration.
>>>>
>>>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>>>---
>>>> include/net/devlink.h        |   3 +
>>>> include/uapi/linux/devlink.h |  11 ++
>>>> net/core/devlink.c           | 234 +++++++++++++++++++++++++++++++++++++++++++
>>>> 3 files changed, 248 insertions(+)
>>>>
>>>>diff --git a/include/net/devlink.h b/include/net/devlink.h
>>>>index b9654e1..bd64623 100644
>>>>--- a/include/net/devlink.h
>>>>+++ b/include/net/devlink.h
>>>>@@ -270,6 +270,9 @@ struct devlink_ops {
>>>>       int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
>>>>       int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
>>>>       int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
>>>>+      int (*perm_config_get)(struct devlink *devlink, u32 param, u32 *value);
>>>>+      int (*perm_config_set)(struct devlink *devlink, u32 param, u32 value,
>>>
>>> Please use enum instead of "u32 param". Also, what would happen if the
>>> value is >u32, like string for example? I believe we need to take it into
>>> the consideration for the UAPI sake.
>>>
>>>
>>
>>Using enum instead of u32 param: ok, will do in v3, thanks.
>>
>>Value > u32:  In the RFC and v1 versions of the patch, each parameter
>>was its own attribute, so could have its own type (u32, string,
>>whatever).  In v2, trying to move to nested parameters w/ parameter
>>being an enum, as requested, it seems to mean that the parameter value
>>now must be defined as a specific type, so I went with u32.
>
> Why? I have to be missing something. In the nest all is same as outside
> of the nest.
>
> Also, please see team_nl_cmd_options_set() where something similar is
> done, for multiple option types.
>
>

Okay, I can implement similar to that driver.  In the current
devlink.c/devlink.h, all attributes have specific types, and aren't
dynamic types like the "data" attribute in the team driver, so I had
thought having specific types defined for each attribute was required
in devlink.
