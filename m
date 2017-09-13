From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2] geneve: Fix setting ttl value in collect metadata mode
Date: Wed, 13 Sep 2017 13:22:18 -0700
Message-ID: <CAOrHB_CXwNSwo_fir7wpFi-HiCTPa4MaeT-SoiDKwTY582nEVg@mail.gmail.com>
References: <1505199911-21153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAOrHB_AWuWXw1fLvY2arKf0XO6GM0g379KDadwf=ymz47cTOMw@mail.gmail.com> <95A24784-0575-47CE-A485-B2A59911262A@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: =?UTF-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <95A24784-0575-47CE-A485-B2A59911262A@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 13, 2017 at 4:15 AM, 严海双 <yanhaishuang@cmss.chinamobile.com> wrote:
>
>
>> On 2017年9月13日, at 上午7:43, Pravin Shelar <pshelar@ovn.org> wrote:
>>
>> On Tue, Sep 12, 2017 at 12:05 AM, Haishuang Yan
>> <yanhaishuang@cmss.chinamobile.com> wrote:
>>> Similar to vxlan/ipip tunnel, if key->tos is zero in collect metadata
>>> mode, tos should also fallback to ip{4,6}_dst_hoplimit.
>>>
>>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>>>
>>> ---
>>> Changes since v2:
>>>  * Make the commit message more clearer.
>>> ---
>>> drivers/net/geneve.c | 6 ++----
>>> 1 file changed, 2 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>>> index f640407..d52a65f 100644
>>> --- a/drivers/net/geneve.c
>>> +++ b/drivers/net/geneve.c
>>> @@ -834,11 +834,10 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>>>        sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
>>>        if (geneve->collect_md) {
>>>                tos = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
>>> -               ttl = key->ttl;
>>>        } else {
>>>                tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, ip_hdr(skb), skb);
>>> -               ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
>>>        }
>>> +       ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
>>>        df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
>>>
>> This changes user API of Geneve collect-metadata mode. I do not see
>> good reason for this. Why user can not set right TTL for the flow?
>>
>
> For example, I test this case with script samples/bpf/test_tunnel_bpf.sh,
> and modify samples/bpf/tcbpf2_kern.c with following patch:
>
But user is suppose to specify the TTL in collect-md mode for Geneve
tunnel. That is the API.
