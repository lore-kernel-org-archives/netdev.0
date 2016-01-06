From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key
Date: Wed, 6 Jan 2016 15:11:35 +0800
Message-ID: <568CBE27.7030004@oracle.com>
References: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
 <20160106.011835.39198953316515142.davem@davemloft.net>
 <568CB501.1010106@oracle.com> <568CB7EB.7080705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zhuyj <zyjzyj2000@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22762 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcAFHIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 02:08:13 -0500
In-Reply-To: <568CB7EB.7080705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm, we are not changing device MTU but PMTU...

thanks,
wengang

=E5=9C=A8 2016=E5=B9=B401=E6=9C=8806=E6=97=A5 14:44, zhuyj =E5=86=99=E9=
=81=93:
> IMHO, the following comments will help us all.
>
>         case NETDEV_CHANGEMTU:
>                 /* TODO: Should slaves be allowed to
>                  * independently alter their MTU?  For
>                  * an active-backup bond, slaves need
>                  * not be the same type of device, so
>                  * MTUs may vary.  For other modes,
>                  * slaves arguably should have the
>                  * same MTUs. To do this, we'd need to
>                  * take over the slave's change_mtu
>                  * function for the duration of their
>                  * servitude.
>                  */
>                 break;
>
> Best Regards!
> Zhu Yanjun
>
> On 01/06/2016 02:32 PM, Wengang Wang wrote:
>>
>>
>> =E5=9C=A8 2016=E5=B9=B401=E6=9C=8806=E6=97=A5 14:18, David Miller =E5=
=86=99=E9=81=93:
>>> From: Wengang Wang <wen.gang.wang@oracle.com>
>>> Date: Wed,  6 Jan 2016 13:49:28 +0800
>>>
>>>> @@ -523,11 +523,20 @@ static void build_skb_flow_key(struct flowi4=
=20
>>>> *fl4, const struct sk_buff *skb,
>>>>                      const struct sock *sk)
>>>>   {
>>>>       const struct iphdr *iph =3D ip_hdr(skb);
>>>> -    int oif =3D skb->dev->ifindex;
>>>> +    int oif;
>>>> +    struct net_device *master =3D NULL;
>>>> +
>>>>       u8 tos =3D RT_TOS(iph->tos);
>>>>       u8 prot =3D iph->protocol;
>>>>       u32 mark =3D skb->mark;
>>> Please fix the stlye of these variable declarations:
>>>
>>> 1) Order them from longest line to shortest line, also known
>>>     as "reverse christmas tree" layout.
>>>
>>> 2) Do not add an empty line in the middle of these variable
>>>     declarations.
>> OK, will do in second drop.
>>
>> thanks,
>> wengang
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
