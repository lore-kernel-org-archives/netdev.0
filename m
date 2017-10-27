From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v4 02/10] devlink: Adding SR-IOV enablement perm
 config param
Date: Fri, 27 Oct 2017 17:30:06 -0400
Message-ID: <CA+Jmh7FgiG_FPSGDhZOYpRAUkDVH53q=zYWJ7iEVLs1KvfL-Bw@mail.gmail.com>
References: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
 <1509137654-1580-3-git-send-email-steven.lin1@broadcom.com> <20171027210651.GD1980@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>,
        Yuval Mintz <yuvalm@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:51960 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdJ0Va1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 17:30:27 -0400
Received: by mail-qt0-f194.google.com with SMTP id h4so10086538qtk.8
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:30:27 -0700 (PDT)
In-Reply-To: <20171027210651.GD1980@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 5:06 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Oct 27, 2017 at 10:54:06PM CEST, steven.lin1@broadcom.com wrote:
>>Adding DEVLINK_PERM_CONFIG_SRIOV_ENABLED permanent config
>>parameter.  Value is permanent, so becomes the new default
>
> Avoid the double space.

Ok.

>
>
>>value for this device.
>>
>>  DEVLINK_PERM_CONFIG_DISABLE = Disable SR-IOV
>>  DEVLINK_PERM_CONFIG_ENABLE  = Enable SR-IOV
>>
>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>---
>> include/uapi/linux/devlink.h | 14 +++++++++++++-
>> net/core/devlink.c           |  1 +
>> 2 files changed, 14 insertions(+), 1 deletion(-)
>>
>>diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>>index b3a0b2a..9a41f6e 100644
>>--- a/include/uapi/linux/devlink.h
>>+++ b/include/uapi/linux/devlink.h
>>@@ -256,8 +256,20 @@ enum devlink_dpipe_header_id {
>>       DEVLINK_DPIPE_HEADER_IPV6,
>> };
>>
>>-/* Permanent config parameters */
>>+enum devlink_perm_config_enabled {
>>+      DEVLINK_PERM_CONFIG_DISABLE,
>>+      DEVLINK_PERM_CONFIG_ENABLE,
>>+};
>>+
>>+/* Permanent config parameters:
>>+ * DEVLINK_PERM_CONFIG_SRIOV_ENABLED: Configures whether SR-IOV PCI capability
>>+ * provided by device.
>
> I don't understand the sentense :/

It means that this parameter controls whether the device advertises
SR-IOV PCI capability -- perhaps I should say "advertised" rather than
"provided"?  Ok, will do that...

>
>
>>+ *   DEVLINK_PERM_CONFIG_DISABLE = disable SR-IOV
>>+ *   DEVLINK_PERM_CONFIG_ENABLE  = enable SR-IOV
>
> These comments should be at the enum values, not here.

Ok.

>
>
>>+ */
>> enum devlink_perm_config_param {
>>+      DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
>>+
>>       __DEVLINK_PERM_CONFIG_MAX,
>>       DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
>> };
>>diff --git a/net/core/devlink.c b/net/core/devlink.c
>>index a7fa7cc..395c93c 100644
>>--- a/net/core/devlink.c
>>+++ b/net/core/devlink.c
>>@@ -1569,6 +1569,7 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
>> static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
>>
>> static const u8 devlink_perm_cfg_param_types[DEVLINK_PERM_CONFIG_MAX + 1] = {
>>+      [DEVLINK_PERM_CONFIG_SRIOV_ENABLED] = NLA_U8,
>> };
>>
>> static int devlink_nl_single_param_get(struct sk_buff *msg,
>>--
>>2.7.4
>>
