From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for February 18 (netfilter)
Date: Thu, 18 Feb 2010 09:50:08 -0800
Message-ID: <4B7D7DD0.4050802@oracle.com>
References: <20100218204937.54a613d2.sfr@canb.auug.org.au> <4B7D70D0.9090003@oracle.com> <4B7D72FF.4010401@trash.net> <4B7D7617.9070600@oracle.com> <4B7D7CAA.1070605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7D7CAA.1070605@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/10 09:45, Patrick McHardy wrote:
> Randy Dunlap wrote:
>> On 02/18/10 09:03, Patrick McHardy wrote:
>>> Randy Dunlap wrote:
>>>> On 02/18/10 01:49, Stephen Rothwell wrote:
>>>>> Hi all,
>>>>>
>>>>> Changes since 20100217:
>>>>>
>>>>> The net tree lost its build failure but gained a conflict against the kvm
>>>>> tree.
>>>>
>>>> include/net/netfilter/nf_conntrack.h:94: error: field 'ct_general' has incomplete type
>>>> include/net/netfilter/nf_conntrack.h:178: error: 'const struct sk_buff' has no member named 'nfct'
>>>> include/net/netfilter/nf_conntrack.h:185: error: implicit declaration of function 'nf_conntrack_put'
>>>> include/net/netfilter/nf_conntrack.h:294: error: 'const struct sk_buff' has no member named 'nfct'
>>>> net/ipv4/netfilter/nf_defrag_ipv4.c:45: error: 'struct sk_buff' has no member named 'nfct'
>>>> net/ipv4/netfilter/nf_defrag_ipv4.c:46: error: 'struct sk_buff' has no member named 'nfct'
>>>>
>>>> CONFIG_NF_CONNTRACK is not enabled
>>>> but CONFIG_NF_DEFRAG_IPV4=y.  It is "select"ed by
>>>> NETFILTER_XT_MATCH_SOCKET and NETFILTER_XT_TARGET_TPROXY,
>>>> both of which are enabled.
>>>>
>>>> Hm, NETFILTER_XT_MATCH_SOCKET depends on !NF_CONNTRACK || NF_CONNTRACK.
>>>> Maybe NETFILTER_XT_TARGET_TPROXY needs to do that also.  No, that would
>>>> go against that config option's help text:
>>> No, the problem is use of skb->nfct without CONFIG_NF_CONNTRACK.
>>>
>>> This patch should fix it.
>>
>> Nope:
>>
>> In file included from /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack_extend.h:4,
>>                  from /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack_zones.h:4,
>>                  from /lnx/src/NEXT/linux-next-20100218/net/ipv4/netfilter/nf_defrag_ipv4.c:19:
>> /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack.h:94: error: field 'ct_general' has incomplete type
>> /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack.h: In function 'nf_ct_get':
> 
> Ah I see, we must not include nf_conntrack.h at all. Eventually
> we need to fix this properly by making nf_conntrack.h usable
> even with NF_CONNTRACK=n, but that's a more complicated change.
> 
> This patch works fine for me using your config:
> 

Ack.  Thanks.

-- 
~Randy
