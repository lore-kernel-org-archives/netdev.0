From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Wed, 12 Nov 2014 08:03:40 -0500
Message-ID: <54635AAC.3080600@mojatatu.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us> <1415700789-9171-2-git-send-email-jiri@resnulli.us> <CAHA+R7O=_h4HEF01wFacteawVX-2uvMiPjUAExKV6GphSJySzg@mail.gmail.com> <20141112123445.GE1882@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>, Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:41539 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaKLNDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 08:03:44 -0500
Received: by mail-ie0-f177.google.com with SMTP id tp5so13406944ieb.22
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 05:03:43 -0800 (PST)
In-Reply-To: <20141112123445.GE1882@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/14 07:34, Jiri Pirko wrote:
> Tue, Nov 11, 2014 at 11:33:21PM CET, cwang@twopensource.com wrote:
>> On Tue, Nov 11, 2014 at 2:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> +static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>>> +                        struct nlattr *est, struct tc_action *a,
>>> +                        int ovr, int bind)
>>> +{
>>> +       struct nlattr *tb[TCA_VLAN_MAX + 1];
>>> +       struct tc_vlan *parm;
>>> +       struct tcf_vlan *v;
>>> +       int action;
>>> +       __be16 push_vid = 0;
>>> +       __be16 push_proto = 0;
>>> +       int ret = 0;
>>> +       int err;
>>> +
>>> +       if (!nla)
>>> +               return -EINVAL;
>>> +
>>> +       err = nla_parse_nested(tb, TCA_VLAN_MAX, nla, vlan_policy);
>>> +       if (err < 0)
>>> +               return err;
>>> +
>>> +       if (!tb[TCA_VLAN_PARMS])
>>> +               return -EINVAL;
>>> +       parm = nla_data(tb[TCA_VLAN_PARMS]);
>>> +       switch (parm->v_action) {
>>> +       case TCA_VLAN_ACT_POP:
>>> +               break;
>>> +       case TCA_VLAN_ACT_PUSH:
>>> +               if (!tb[TCA_VLAN_PUSH_VLAN_ID])
>>> +                       return -EINVAL;
>>> +               push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
>>
>> nla_get_be16() ?
>
> No. I made this the same as it is done in net/8021q/vlan_netlink.c
>

It just happens that user space passes it to you in BE already.
So this works out because skb_vlan_push expects that to be in BE
as in:
int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)



cheers,
jamal
