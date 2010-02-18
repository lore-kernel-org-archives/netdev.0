From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: kernel stack  trace using conntrack
Date: Thu, 18 Feb 2010 13:18:42 +0100
Message-ID: <4B7D3022.9030405@netfilter.org>
References: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D04@FRSPX100.fr01.awl.atosorigin.net>	 <1266313889.3045.1.camel@edumazet-laptop>	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net>	 <1266318928.3045.38.camel@edumazet-laptop>  <4B7A9E95.103@netfilter.org> <1266327917.3045.55.camel@edumazet-laptop> <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC905D@FRSPX100.fr01.awl.atosorigin.net> <4B7D17CE.6010805@trash.net> <4B7D1E32.6000705@netfilter.org> <4B7D215A.6060400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ramblewski David <David.Ramblewski@atosorigin.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7D215A.6060400@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>>> Ramblewski David wrote:
>>>> Hi Eric,
>>>>
>>>> The conntrack patch works successfully.
>>>>
>>>>>> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
>>>>>> index 0ffe689..d2657aa 100644
>>>>>> --- a/net/netfilter/nf_conntrack_netlink.c
>>>>>> +++ b/net/netfilter/nf_conntrack_netlink.c
>>>>>> @@ -923,7 +923,7 @@ ctnetlink_change_status(struct nf_conn *ct, const struct nlattr * const cda[])
>>>>>>     unsigned int status = ntohl(nla_get_be32(cda[CTA_STATUS]));
>>>>>>     d = ct->status ^ status;
>>>>>>
>>>>>> -   if (d & (IPS_EXPECTED|IPS_CONFIRMED|IPS_DYING))
>>>>>> +   if (d & (IPS_EXPECTED|IPS_DYING))
>>>>>>             /* unchangeable */
>>>>>>             return -EBUSY;
>>>>> I think that we should explicitly report if the user unsets
>>>>> IPS_CONFIRMED. Please, don't change this.
>>>>>
>>>>> Apart from that, the patch seems fine to me. Thanks!
>>>> Problem is we now (I mean after my patch) enter
>>>> ctnetlink_change_status() with ct->status being null (or at least,
>>>> IPS_CONFIRMED not set)
>>> Pablo, please let me know whether you want me to apply this.
>> ctnetlink_change_helper() also calls nf_ct_ext_add() for conntracks that
>> are confirmed (in case of a helper update for an existing conntrack).
>> That would also trigger the assertion. If we want to support helper
>> assignation via ctnetlink for existing conntracks, we will need to add
>> locking to the conntrack extension infrastructure to avoid races.
>>
>> I don't see a clear solution for this yet.
> 
> I see, this is indeed a problem. Since the helper is known at the
> first event, we could restrict this to only allow manual assignment
> for newly created conntracks. Most helpers probably can't properly
> cope with connections not seen from the beginning anyways.

Indeed, changing the helper in the middle of the road doesn't make too
much sense to me either. I can send you a patch for this along today,
I'll find some spare time to do it.
