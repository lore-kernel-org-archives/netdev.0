From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH] netfilter: Fix build failure when ipv6 but xt_tproxy
 is built in
Date: Wed, 06 Apr 2011 14:08:50 +0200
Message-ID: <4D9C57D2.20303@balabit.hu>
References: <1301451199.14261.327.camel@gandalf.stny.rr.com>	 <20110329.223536.245392030.davem@davemloft.net>	 <4D99CDA0.3030305@trash.net> <1302014626.67568.1.camel@nienna.balabit> <4D9B2BF2.2010606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D9B2BF2.2010606@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 04/05/2011 04:49 PM, Patrick McHardy wrote:
>> What about something like this?
>>
>> diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
>> index dcfd57e..1ef0e56 100644
>> --- a/net/netfilter/xt_TPROXY.c
>> +++ b/net/netfilter/xt_TPROXY.c
>> @@ -283,10 +283,10 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
>>         const struct in6_addr *laddr;
>>         __be16 lport;
>>         int thoff;
>> -       int tproto;
>> +       u8 tproto = iph->nexthdr;
>>  
>> -       tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
>> -       if (tproto < 0) {
>> +       thoff = ipv6_skip_exthdr(skb, sizeof(*iph), &tproto);
>> +       if (thoff < 0) {
>>                 pr_debug("unable to find transport header in IPv6 packet, dropping\n");
>>                 return NF_DROP;
>>         }
> 
> Looks good to me. Please formally submit this including a Signed-off-by:
> line and I'll push it upstream.

Will do, as soon as I have a chance to run the test suite. Thanks Patrick.

-- 
KOVACS Krisztian
