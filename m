From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Thu, 23 Jul 2015 17:25:51 +0200
Message-ID: <55B1077F.1090501@6wind.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com> <55B101DC.6040609@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33810 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbbGWPZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 11:25:54 -0400
Received: by wibud3 with SMTP id ud3so29535373wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 08:25:53 -0700 (PDT)
In-Reply-To: <55B101DC.6040609@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/07/2015 17:01, roopa a =E9crit :
> On 7/23/15, 7:22 AM, Nicolas Dichtel wrote:
[snip]
>> +static inline u32 *lwt_netns_info(struct lwtunnel_state *lwtstate)
>> +{
>> +    return (u32 *)lwtstate->data;
>> +}
>> +
>> +static inline int skb_lwt_netns_info(struct sk_buff *skb)
>> +{
>> +    if (skb->protocol =3D=3D htons(ETH_P_IP)) {
>> +        struct rtable *rt =3D (struct rtable *)skb_dst(skb);
>> +
>> +        if (rt && rt->rt_lwtstate)
>> +            return *lwt_netns_info(rt->rt_lwtstate);
>> +    } else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
>> +        struct rt6_info *rt6 =3D (struct rt6_info *)skb_dst(skb);
>> +
>> +        if (rt6 && rt6->rt6i_lwtstate)
>> +            return *lwt_netns_info(rt6->rt6i_lwtstate);
>> +    }
>> +
>> +    return NETNSA_NSID_NOT_ASSIGNED;
>> +}
>>   #endif /* __NET_LWTUNNEL_H */
> since these apis' don't have to be netns specific,
> Can they just be named lwtunnel_get_state_data and skb_lwtunnel_state=
 ?
They are specific to netns because lwtstate->data is interpreted as an =
u32 *.
But I agree that a test is missing against lwtstate->type to ensure tha=
t data
will be a nsid.

>
> and seems like they should be declared for both CONFIG_LWTUNNEL 'y' a=
nd 'n'.
It is outside the "#ifdef CONFIG_LWTUNNEL". I can successfully compile =
with and
without CONFIG_LWTUNNEL.

Thank you,
Nicolas
