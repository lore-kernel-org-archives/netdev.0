From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH linux v1 net-next 4/4] bonding: add netlink support for
 sys prio, actor sys mac, and port key
Date: Mon, 04 May 2015 16:48:39 -0400
Message-ID: <5547DB27.60608@cumulusnetworks.com>
References: <cover.1430498637.git.jtoppins@cumulusnetworks.com> <73eb78d846c220d223f68a3b29f42eff011795fd.1430498637.git.jtoppins@cumulusnetworks.com> <CAF2d9jjKmYd7pVVVnsXQkGoysQy09Ro4VFA7a8etFYYTzv9+Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:34416 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbEDUsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:48:42 -0400
Received: by qcyk17 with SMTP id k17so78436425qcy.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 13:48:41 -0700 (PDT)
In-Reply-To: <CAF2d9jjKmYd7pVVVnsXQkGoysQy09Ro4VFA7a8etFYYTzv9+Ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/15 7:15 PM, Mahesh Bandewar wrote:
>>
>> @@ -548,6 +585,19 @@ static int bond_fill_info(struct sk_buff *skb,
>>                         bond->params.ad_select))
>>                  goto nla_put_failure;
>>
>> +       if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
>> +                       bond->params.ad_actor_sys_prio))
>> +               goto nla_put_failure;
>> +
>> +       if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
>> +                       bond->params.ad_user_port_key))
>> +               goto nla_put_failure;
>> +
>> +       if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
>> +                   sizeof(bond->params.ad_actor_system),
>> +                   &bond->params.ad_actor_system))
>> +               goto nla_put_failure;
>> +
> I think this does not make sense for MODE != 8023AD. Shouldn't this be
> inside next block which is for the 802.3ad mode?
>
>>          if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>>                  struct ad_info info;
>>
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index d9cd192..6d6e502 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -417,6 +417,9 @@ enum {
>>          IFLA_BOND_AD_LACP_RATE,
>>          IFLA_BOND_AD_SELECT,
>>          IFLA_BOND_AD_INFO,
>> +       IFLA_BOND_AD_ACTOR_SYS_PRIO,
>> +       IFLA_BOND_AD_USER_PORT_KEY,
>> +       IFLA_BOND_AD_ACTOR_SYSTEM,
> Even though this is available / stored in bond->param, I feel that
> these belong to IFLA_BOND_AD_INFO_, no?

Can see it fitting in there. Not sure of the history of the AD_INFO_* 
object. Evaluating implementation, will respond tomorrow with conclusion.

>
>>          __IFLA_BOND_MAX,
>>   };
>>
>> --
>> 1.7.10.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
