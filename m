From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net 1/7] openvswitch: Make LABELS name more consistent
Date: Wed, 30 Sep 2015 18:21:47 -0700
Message-ID: <CANr6G5x8gixq8sn7+u=0VHwOZLMEFLA1+986DEVah3O0is4HiA@mail.gmail.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
 <1443566380-22640-2-git-send-email-joestringer@nicira.com> <CALnjE+riooX7ZzWh2FBXn2V4YZWx2jjJdRMDkNVQQbDbdeDRUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALnjE+riooX7ZzWh2FBXn2V4YZWx2jjJdRMDkNVQQbDbdeDRUg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 September 2015 at 17:31, Pravin Shelar <pshelar@nicira.com> wrote:
> On Tue, Sep 29, 2015 at 3:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
>> Conntrack LABELS (plural) are exposed by conntrack; rename the OVS name
>> for these to be consistent with conntrack.
>>
>> Fixes: c2ac667 "openvswitch: Allow matching on conntrack label"
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>> ---
>>  include/uapi/linux/openvswitch.h |  4 ++--
>>  net/openvswitch/actions.c        |  2 +-
>>  net/openvswitch/conntrack.c      | 10 +++++-----
>>  net/openvswitch/flow_netlink.c   | 14 +++++++-------
>>  4 files changed, 15 insertions(+), 15 deletions(-)
>>
> ...
>
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> index 002a755..8c5d482c 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>> @@ -179,7 +179,7 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
>>                 return -EMSGSIZE;
>>
>>         if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
>> -           nla_put(skb, OVS_KEY_ATTR_CT_LABEL, sizeof(key->ct.label),
>> +           nla_put(skb, OVS_KEY_ATTR_CT_LABELS, sizeof(key->ct.label),
>>                     &key->ct.label))
>>                 return -EMSGSIZE;
>>
>> @@ -545,7 +545,7 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
>>                                     .maxlen = sizeof(u16) },
>>         [OVS_CT_ATTR_MARK]      = { .minlen = sizeof(struct md_mark),
>>                                     .maxlen = sizeof(struct md_mark) },
>> -       [OVS_CT_ATTR_LABEL]     = { .minlen = sizeof(struct md_label),
>> +       [OVS_CT_ATTR_LABELS]    = { .minlen = sizeof(struct md_label),
>>                                     .maxlen = sizeof(struct md_label) },
>>         [OVS_CT_ATTR_HELPER]    = { .minlen = 1,
>>                                     .maxlen = NF_CT_HELPER_NAME_LEN }
>> @@ -593,7 +593,7 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
>>                 }
>>  #endif
>>  #ifdef CONFIG_NF_CONNTRACK_LABELS
>> -               case OVS_CT_ATTR_LABEL: {
>> +               case OVS_CT_ATTR_LABELS: {
>>                         struct md_label *label = nla_data(a);
>>
>>                         info->label = *label;
>> @@ -633,7 +633,7 @@ bool ovs_ct_verify(struct net *net, enum ovs_key_attr attr)
>>             attr == OVS_KEY_ATTR_CT_MARK)
>>                 return true;
>>         if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
>> -           attr == OVS_KEY_ATTR_CT_LABEL) {
>> +           attr == OVS_KEY_ATTR_CT_LABELS) {
>>                 struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
>>
>>                 return ovs_net->xt_label;
>> @@ -711,7 +711,7 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
>>                     &ct_info->mark))
>>                 return -EMSGSIZE;
>>         if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
>> -           nla_put(skb, OVS_CT_ATTR_LABEL, sizeof(ct_info->label),
>> +           nla_put(skb, OVS_CT_ATTR_LABELS, sizeof(ct_info->label),
>>                     &ct_info->label))
>>                 return -EMSGSIZE;
>>         if (ct_info->helper) {
>> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
>> index 5c030a4..ea82cd5 100644
>> --- a/net/openvswitch/flow_netlink.c
>> +++ b/net/openvswitch/flow_netlink.c
>> @@ -294,7 +294,7 @@ size_t ovs_key_attr_size(void)
>>                 + nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
>>                 + nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
>>                 + nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
>> -               + nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABEL */
>> +               + nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
>>                 + nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
>>                 + nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
>>                 + nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
>> @@ -352,7 +352,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>>         [OVS_KEY_ATTR_CT_STATE]  = { .len = sizeof(u8) },
>>         [OVS_KEY_ATTR_CT_ZONE]   = { .len = sizeof(u16) },
>>         [OVS_KEY_ATTR_CT_MARK]   = { .len = sizeof(u32) },
>> -       [OVS_KEY_ATTR_CT_LABEL]  = { .len = sizeof(struct ovs_key_ct_label) },
>> +       [OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_label) },
>>  };
> After this change, struct ovs_key_ct_label and other reference to
> label also should be renamed to labels. is there reason you did only
> this one?

Nope, fair point. I'll fix them.
