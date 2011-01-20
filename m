From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH resend] netfilter: place in source hash after SNAT is
 done
Date: Thu, 20 Jan 2011 15:51:04 +0100
Message-ID: <4D384BD8.9080709@trash.net>
References: <1295090930-16671-1-git-send-email-xiaosuo@gmail.com> <4D35A0F2.5010908@trash.net> <AANLkTimPEaXiiFiyD7Anvg+x5zJUsF04P_yPbj8KzYaF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimPEaXiiFiyD7Anvg+x5zJUsF04P_yPbj8KzYaF@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 19.01.2011 01:03, schrieb Changli Gao:
> On Tue, Jan 18, 2011 at 10:17 PM, Patrick McHardy <kaber@trash.net> wrote:
>>>  net/ipv4/netfilter/nf_nat_core.c |   18 +++++++++++-------
>>>  1 file changed, 11 insertions(+), 7 deletions(-)
>>> diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
>>> index c04787c..51ce55a 100644
>>> --- a/net/ipv4/netfilter/nf_nat_core.c
>>> +++ b/net/ipv4/netfilter/nf_nat_core.c
>>> @@ -221,7 +221,14 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
>>>          manips not an issue.  */
>>>       if (maniptype == IP_NAT_MANIP_SRC &&
>>>           !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
>>> -             if (find_appropriate_src(net, zone, orig_tuple, tuple, range)) {
>>> +             /* try the original tuple first */
>>
>> This doesn't seem to be related to the hashing change. Please describe
>> the intention behind this change.
> 
> Currently, we add the ct at the head of the corresponding bucket of
> the source hash table after DNAT is done, so when we do SNAT, the
> original ct will be tried first. This change is used to keep this
> behavior.

Thanks for the explanation, applied.
