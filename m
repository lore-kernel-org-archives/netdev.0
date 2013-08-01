From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v5 6/7] vxlan: Add tx-vlan offload support.
Date: Thu, 1 Aug 2013 10:24:39 -0700
Message-ID: <CALnjE+qL9+r=c1a-9E6BgQPn52YkEwtY6EZOjc+A_7HcCO1hfg@mail.gmail.com>
References: <1375312487-18789-1-git-send-email-pshelar@nicira.com>
	<51FA5E93.3070308@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:43423 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755293Ab3HARYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 13:24:40 -0400
Received: by mail-qe0-f47.google.com with SMTP id b10so1275977qen.34
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 10:24:39 -0700 (PDT)
In-Reply-To: <51FA5E93.3070308@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 1, 2013 at 6:11 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 01-08-2013 3:14, Pravin B Shelar wrote:
>
>> Following patch allows transmit side vlan offload for vxlan
>> devices.
>
>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>> v2-v3:
>>   - Set NETIF_F_HW_VLAN_STAG_TX feature.
>>   - Added WARN on vlan tag push.
>>   - Fixed hw_features.
>> ---
>>   drivers/net/vxlan.c |   18 +++++++++++++++++-
>>   1 files changed, 17 insertions(+), 1 deletions(-)
>
>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index f9c7c75..2f35a2b 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>
> [...]
>
>> @@ -1123,13 +1124,25 @@ int vxlan_xmit_skb(struct net *net, struct
>> vxlan_sock *vs,
>
> [...]
>
>> +       if (vlan_tx_tag_present(skb)) {
>> +               if (unlikely(!__vlan_put_tag(skb,
>> +                                            skb->vlan_proto,
>> +                                            vlan_tx_tag_get(skb)))) {
>> +                       WARN_ON(1);
>> +                       return -ENOMEM;
>> +               }
>
>
>                 if (WARN_ON(!__vlan_put_tag(skb,
>                                             skb->vlan_proto,
>                                             vlan_tx_tag_get(skb))))
>                         return -ENOMEM;
>
> should be equivalent.

ok. I will update the patch.

>
> WBR, Sergei
>
