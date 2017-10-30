From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v5 02/10] devlink: Adding SR-IOV enablement perm
 config param
Date: Mon, 30 Oct 2017 16:17:16 -0400
Message-ID: <CA+Jmh7HX7xhfYjAmVU+yRqh9NE5Hys8p9_ic_vdZ_m8Os85buw@mail.gmail.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
 <1509374776-45869-3-git-send-email-steven.lin1@broadcom.com> <20171030172049.GG4115@nanopsycho.orion>
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
Received: from mail-qt0-f194.google.com ([209.85.216.194]:46541 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932766AbdJ3URh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:17:37 -0400
Received: by mail-qt0-f194.google.com with SMTP id 1so18068568qtn.3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:17:36 -0700 (PDT)
In-Reply-To: <20171030172049.GG4115@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 1:20 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Oct 30, 2017 at 03:46:08PM CET, steven.lin1@broadcom.com wrote:
>>Adding DEVLINK_PERM_CONFIG_SRIOV_ENABLED permanent config
>>parameter; this parameter controls whether the device
>>advertises the SR-IOV PCI capability. Value is permanent, so
>>becomes the new default value for this device.
>>
>>  DEVLINK_PERM_CONFIG_DISABLE = Disable SR-IOV
>>  DEVLINK_PERM_CONFIG_ENABLE  = Enable SR-IOV
>>
>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>---
>> include/uapi/linux/devlink.h | 18 +++++++++++++++++-
>> net/core/devlink.c           |  1 +
>> 2 files changed, 18 insertions(+), 1 deletion(-)
>>
>>diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>>index 55e35f2..1c5d4ae 100644
>>--- a/include/uapi/linux/devlink.h
>>+++ b/include/uapi/linux/devlink.h
>>@@ -256,8 +256,24 @@ enum devlink_dpipe_header_id {
>>       DEVLINK_DPIPE_HEADER_IPV6,
>> };
>>
>>-/* Permanent config parameters */
>>+/* Permanent config parameter enable/disable
>>+ * DEVLINK_PERM_CONFIG_DISABLE = disable a permanent config parameter
>>+ * DEVLINK_PERM_CONFIG_ENBALE  = enable a permanent config parameter
>>+ */
>>+enum devlink_perm_config_enabled {
>>+      DEVLINK_PERM_CONFIG_DISABLE,
>>+      DEVLINK_PERM_CONFIG_ENABLE,
>>+};
>
>
> Basically, this is "bool"
>
> Why don't you use some own enum instead of NLA_U*. Like team does for
> example:
>
> enum team_option_type {
>         TEAM_OPTION_TYPE_U32,
>         TEAM_OPTION_TYPE_STRING,
>         TEAM_OPTION_TYPE_BINARY,
>         TEAM_OPTION_TYPE_BOOL,
>         TEAM_OPTION_TYPE_S32,
> };
>
>

I had added enum devlink_perm_config_type in v5 based on your comments
in v4 - I will add BOOL if it helps clarity.

>
>>+
>>+/* Permanent config parameters:
>>+ * DEVLINK_PERM_CONFIG_SRIOV_ENABLED: Configures whether SR-IOV PCI capability
>>+ * is advertised by the device.
>>+ *   DEVLINK_PERM_CONFIG_DISABLE = disable SR-IOV
>>+ *   DEVLINK_PERM_CONFIG_ENABLE  = enable SR-IOV
>>+ */
>> enum devlink_perm_config_param {
>>+      DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
>
>
> Please align "ENABLED" vs "ENABLE".
> The rest of devlink code uses "ENABLED"
>

Ok.

>
>>+
>>       __DEVLINK_PERM_CONFIG_MAX,
>>       DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
>> };
>>diff --git a/net/core/devlink.c b/net/core/devlink.c
>>index 5e77408..b4d43c29 100644
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
