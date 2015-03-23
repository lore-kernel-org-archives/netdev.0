From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2 2/5] mpls: Remove incorrect PHP comment
Date: Mon, 23 Mar 2015 13:16:41 -0500
Message-ID: <87h9tb37g6.fsf@x220.int.ebiederm.org>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-3-git-send-email-rshearma@brocade.com>
	<87fv8wals4.fsf@x220.int.ebiederm.org> <550FF9C9.2000308@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:52741 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbCWSUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 14:20:34 -0400
In-Reply-To: <550FF9C9.2000308@brocade.com> (Robert Shearman's message of
	"Mon, 23 Mar 2015 11:32:25 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 22/03/15 19:12, Eric W. Biederman wrote:
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> Popping the last label on the stack does not necessarily imply
>>> performing penultimate hop popping. There is no reason why this
>>> couldn't be the last hop in the network, so remove the comment.
>>
>> So this change I will disagree with.
>>
>> What the code implements is Penultimate hop popping.  Even if you send
>> the packets over loopback that is what the code is doing.
>
> No, RFC3031 s3.16 (https://tools.ietf.org/html/rfc3031#page-18) talks in terms
> of LSRs (label switch routers), not passes through the forwarding
> code.

In very simple terms the code always removes the labels and forwards the
code.  That is by definition penultimate hop popping.  That is all that
is implmeneted in the code today.  And that is what the comment is
noting.

>> This is relevant because I think the code may actually be wrong in the
>> local reception case.  By preforming penultimate hop popping and
>> receving the code on loopback I think this code allows bypassing
>> iptables rules that apply to incoming ip packets.  Certainly there is a
>> loss of information as to which hardware interface the packet came in on
>> that it may be desirable to correct.
>
> Indeed, but network operators may well want to apply different rules to traffic
> coming in as IP versus traffic coming in as MPLS.
>
> This may well merit a comment of its own, but this isn't directly relevant to
> the comment I'm removing.

My point is and what is directly relevant is the case of local delivery
is a hack.  A hack that a pretty strong case can be made that it does
the wrong thing and something we probably should fix before the code
makes it to Linus for 4.1 so the bug does not get cast in stone.

In other words the disparity between the comment and the code indicates
an actual bug, not just a wrong comment.

Eric

>>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>>> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>>> ---
>>>   net/mpls/af_mpls.c | 1 -
>>>   1 file changed, 1 deletion(-)
>>>
>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>> index 0d6763a..bf3459a 100644
>>> --- a/net/mpls/af_mpls.c
>>> +++ b/net/mpls/af_mpls.c
>>> @@ -199,7 +199,6 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>>>   	skb->protocol = htons(ETH_P_MPLS_UC);
>>>
>>>   	if (unlikely(!new_header_size && dec.bos)) {
>>> -		/* Penultimate hop popping */
>>>   		if (!mpls_egress(rt, skb, dec))
>>>   			goto drop;
>>>   	} else {
