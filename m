From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] ip6_tunnel: Correct tos value in collect_md mode
Date: Tue, 13 Jun 2017 17:37:04 +0200
Message-ID: <594006A0.9020801@iogearbox.net>
References: <1497340529-18736-1-git-send-email-yanhaishuang@cmss.chinamobile.com> <593FB700.6020701@iogearbox.net> <0D379591-C5AA-496C-BC00-18005EAA7D21@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, peter.a.dawson@boeing.com, ast@fb.com
To: =?UTF-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0D379591-C5AA-496C-BC00-18005EAA7D21@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2017 03:31 PM, 严海双 wrote:
>> On 13 Jun 2017, at 5:57 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 06/13/2017 09:55 AM, Haishuang Yan wrote:
>>> Same as ip_gre, geneve and vxlan, use key->tos as tos value.
>>
>> Please also add Fixes tag and Cc original authors.
>>
>> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated packets”)
>
> Ok, I will add it, thanks
>
>>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>>> ---
>>>   net/ipv6/ip6_tunnel.c | 4 ++--
>>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
>>> index ef99d59..5f4aff5 100644
>>> --- a/net/ipv6/ip6_tunnel.c
>>> +++ b/net/ipv6/ip6_tunnel.c
>>> @@ -1249,7 +1249,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>>>   		fl6.flowi6_proto = IPPROTO_IPIP;
>>>   		fl6.daddr = key->u.ipv6.dst;
>>>   		fl6.flowlabel = key->label;
>>> -		dsfield = ip6_tclass(key->label);
>>> +		dsfield = key->tos;
>>
>> Not exactly the same as vxlan / geneve. They do use key->tos
>> indeed, but they also set fl6.flowlabel differently:
>>
>>   [...]
>>   prio = info->key.tos;
>>   [...]
>>   fl6->flowlabel = ip6_make_flowinfo(RT_TOS(prio),
>>                                      info->key.label);
>>   [...]
>>
>> But looks like the latter is done later in ip6_tnl_xmit() eventually
>> before the route lookup as per 5f733ee68f9a ("ip6_tunnel: fix traffic
>> class routing for tunnels") fix. However, you still might want to
>> mask key->tos with RT_TOS().
>
> Do you mean this way?

This one from my last comment: dsfield = RT_TOS(key->tos)
