From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 16:45:23 -0400
Message-ID: <553959E3.9070209@mojatatu.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com> <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com> <55381F14.4070708@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36394 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbbDWUq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 16:46:28 -0400
Received: by qgeb100 with SMTP id b100so13990443qge.3
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 13:46:27 -0700 (PDT)
In-Reply-To: <55381F14.4070708@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/15 18:22, Alexei Starovoitov wrote:
> On 4/21/15 10:02 PM, Cong Wang wrote:
>> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov
>> <ast@plumgrid.com> wrote:
>>> TC_ACT_QUEUED was always an alias of TC_ACT_STOLEN.
>>> Get rid of redundant checks in all qdiscs.
>>> Instead do it once.
>>
>> The current code can be easily extended, while your code not.
>> I don't see the need of this change.
>
> well, iproute2 doesn't use TC_ACT_QUEUED action at all and
> TC_ACT_STOLEN is used by mirred. All in-tree qdiscs alias them.
> If you're saying that some future actions together with
> some future qdiscs may take advantage of that, then why they didn't
> use it over the last 10 years?
> Having both that do the same thing is only confusing.
> I think having one value to indicate 'stolen' condition makes TC
> code easier to understand.
> Jamal, what's your take on this?


Sorry - I am on travel so not very helpful/responsive.
Several things:

1) the _XMIT semantics are useful on the egress side because in fact
we do have queues and they can be attached to qdiscs etc.
The TC_ACT_XXX codes were _intentional_ since ingress works as a
classifier shell. The fact that qdiscs dealt with these codes directly
allows for specialized handling. Moving them to a generic function
seems to defeat that purpose. So I am siding with Cong on this.
You probably have some other motivation for doing this which is not 
clear yet? Are you planning to queue things on ingress?

2) the ACT_QUEUED vs STOLEN was supposed to have semantics of something
that was stolen (eg redirection should definetely have been returning
STOLEN not QUEUED); something that queues for later re-injection
(with any/all metadata) was intended to use QUEUED. I believe netfilter
may have  followed suit and introduced similar codes (so it would be
interesting to see how they use them). In any case, it is clear it is
not being used - but i want to point the reason it was there
(which may still be useful; problem is TheLinuxWay is cutnpaste where
someone repeats the code that exists).

cheers,
jamal
