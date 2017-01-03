From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Tue, 3 Jan 2017 14:22:05 +0200
Message-ID: <606f64cb-1744-d44f-8fd1-a4bdb1ca872f@mellanox.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <586ADAFE.1010105@gmail.com>
 <13dfd148-6a5b-cf62-b2b9-1c13e6d31155@mojatatu.com>
 <586B29A4.2060408@gmail.com>
 <92224e21-cd3c-26b0-d8a0-31a07268e553@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30076.outbound.protection.outlook.com ([40.107.3.76]:28208
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932168AbdACMWN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 07:22:13 -0500
In-Reply-To: <92224e21-cd3c-26b0-d8a0-31a07268e553@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/01/2017 13:44, Jamal Hadi Salim wrote:
> On 17-01-02 11:33 PM, John Fastabend wrote:
>> On 17-01-02 05:22 PM, Jamal Hadi Salim wrote:
>
> [..]
>>> Like all cookie semantics it is for storing state. The receiver 
>>> (kernel)
>>> is not just store it and not intepret it. The user when reading it back
>>> simplifies what they have to do for their processing.
>>>
>>>>
>>>> The tuple <ifindex:qdisc:prio:handle> really should be unique why
>>>> not use this for system wide mappings?
>>>>
>>>
>>> I think on a single machine should be enough, however:
>>> typically the user wants to define the value in a manner that
>>> in a distributed system it is unique. It would be trickier to
>>> do so with well defined values such as above.
>>>
>>
>> Just extend the tuple <hostname:ifindex:qdisc:prio:handle> that
>> should be unique in the domain of hostname's, or use some other domain
>> wide machine identifier.
>>
>
> May work for the case of filter identification. The nice thing for
> allowing cookies is you can let the user define it define their
> own scheme.
>
>> Although actions can be shared so the cookie can be shared across
>> filters. Maybe its useful but it doesn't uniquely identify a filter
>> in the shared case but the user would have to specify that case
>> so maybe its not important.
>>
>
> Note: the action cookies and filter cookies are unrelated/orthogonal.
> Their basic concept of stashing something in the cookie to help improve
> what user space does (in our case millions of actions of which some are
> used for accounting) is similar.
> I have no objections to the flow cookies; my main concern was it should
> be applicable to all classifiers not just flower. And the arbitrary size
> of the cookie that you pointed out is questionable.
>
> cheers,
> jamal


Hi all,
Our use case is replacing OVS rules with TC filters for HW offload, and 
you're are right the cookie would
have saved us the mapping from OVS rule ufid to the tc filter 
handle/prio... that was generated for it.
It also was going to be used to store other info like which OVS output 
port corresponds to the ifindex,
so we need 128+32 for now. It helps us with dumping the the flows back, 
when we lose data on crash
or restarting the user space daemon.
HW hints is another thing that might be helpful.
Its binary blob because user/app specifc and its usage might change in 
the future and its and that's why there
is some headroom with size as well.


I don't mind having it on TC level but I didn't want to intervene with 
all filters/TC.
