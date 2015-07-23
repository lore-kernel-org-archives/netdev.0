From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Thu, 23 Jul 2015 08:50:40 -0700
Message-ID: <55B10D50.9010704@cumulusnetworks.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com> <55B101DC.6040609@cumulusnetworks.com> <55B1077F.1090501@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35882 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086AbbGWPuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 11:50:46 -0400
Received: by pdjr16 with SMTP id r16so161878279pdj.3
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 08:50:45 -0700 (PDT)
In-Reply-To: <55B1077F.1090501@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/23/15, 8:25 AM, Nicolas Dichtel wrote:
> Le 23/07/2015 17:01, roopa a =E9crit :
>> On 7/23/15, 7:22 AM, Nicolas Dichtel wrote:
> [snip]
>>> +static inline u32 *lwt_netns_info(struct lwtunnel_state *lwtstate)
>>> +{
>>> +    return (u32 *)lwtstate->data;
>>> +}
>>> +
>>> +static inline int skb_lwt_netns_info(struct sk_buff *skb)
>>> +{
>>> +    if (skb->protocol =3D=3D htons(ETH_P_IP)) {
>>> +        struct rtable *rt =3D (struct rtable *)skb_dst(skb);
>>> +
>>> +        if (rt && rt->rt_lwtstate)
>>> +            return *lwt_netns_info(rt->rt_lwtstate);
>>> +    } else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
>>> +        struct rt6_info *rt6 =3D (struct rt6_info *)skb_dst(skb);
>>> +
>>> +        if (rt6 && rt6->rt6i_lwtstate)
>>> +            return *lwt_netns_info(rt6->rt6i_lwtstate);
>>> +    }
>>> +
>>> +    return NETNSA_NSID_NOT_ASSIGNED;
>>> +}
>>>   #endif /* __NET_LWTUNNEL_H */
>> since these apis' don't have to be netns specific,
>> Can they just be named lwtunnel_get_state_data and skb_lwtunnel_stat=
e ?
> They are specific to netns because lwtstate->data is interpreted as a=
n=20
> u32 *.
> But I agree that a test is missing against lwtstate->type to ensure=20
> that data
> will be a nsid.
>
o ok..., the api's in lwtunnel.h today are not specific to an encap typ=
e.
they are generic, so skb_lwtunnel_state() which returns struct=20
lwtunnel_state could go here.
the encap specific ones can go in the respective callers. Recently=20
thomas added a similar
skb_tunnel_info() for ip tunnels. I did  like to have a generic version=
=20
of your skb_lwt_netns_info in lwtunnel.h. I could use it in my mpls=20
output func too.


>>
>> and seems like they should be declared for both CONFIG_LWTUNNEL 'y'=20
>> and 'n'.
> It is outside the "#ifdef CONFIG_LWTUNNEL". I can successfully compil=
e=20
> with and
> without CONFIG_LWTUNNEL.
ok,

thanks,
Roopa
