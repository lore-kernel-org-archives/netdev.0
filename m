From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: define NF_CT_EXT_* as needed
Date: Mon, 15 Nov 2010 19:19:09 +0800
Message-ID: <AANLkTikxaZ0p4idy5qQmoi9R6Obz1UKECFHS-8LV_vKT@mail.gmail.com>
References: <1289813149-22897-1-git-send-email-xiaosuo@gmail.com> <4CE115C5.20302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CE115C5.20302@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 15, 2010 at 7:13 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> On 15.11.2010 10:25, Changli Gao wrote:
>> =A0#ifdef CONFIG_NF_CONNTRACK_EVENTS
>> diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/n=
et/netfilter/nf_conntrack_extend.h
>> index 0772d29..1a9f96d 100644
>> --- a/include/net/netfilter/nf_conntrack_extend.h
>> +++ b/include/net/netfilter/nf_conntrack_extend.h
>> @@ -7,10 +7,16 @@
>>
>> =A0enum nf_ct_ext_id {
>> =A0 =A0 =A0 NF_CT_EXT_HELPER,
>> +#if defined(CONFIG_NF_NAT) || defined(CONFIG_NF_NAT_MODULE)
>> =A0 =A0 =A0 NF_CT_EXT_NAT,
>> +#endif
>> =A0 =A0 =A0 NF_CT_EXT_ACCT,
>> +#ifdef CONFIG_NF_CONNTRACK_EVENTS
>> =A0 =A0 =A0 NF_CT_EXT_ECACHE,
>> +#endif
>> +#ifdef CONFIG_NF_CONNTRACK_ZONES
>> =A0 =A0 =A0 NF_CT_EXT_ZONE,
>> +#endif
>> =A0 =A0 =A0 NF_CT_EXT_NUM,
>
> What is the purpose of #ifdef'ing the extension IDs?
>

struct nf_ct_ext {
        struct rcu_head rcu;
        u8 offset[NF_CT_EXT_NUM];
        u8 len;
        char data[0];
};

Less IDs make nf_ct_ext smaller.
--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
