From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net v3 2/2] mpls: fix mpls route deletes to not check for route scope
Date: Tue, 02 Jun 2015 17:59:32 -0500
Message-ID: <874mmphg2z.fsf@x220.int.ebiederm.org>
References: <1433226567-23302-3-git-send-email-roopa@cumulusnetworks.com>
	<87a8wholtc.fsf@x220.int.ebiederm.org>
	<556E282E.2040501@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, davem@davemloft.net,
	rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42311 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbbFBXEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 19:04:36 -0400
In-Reply-To: <556E282E.2040501@cumulusnetworks.com>
	(roopa@cumulusnetworks.com's message of "Tue, 02 Jun 2015 15:03:26
	-0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roopa <roopa@cumulusnetworks.com> writes:

> On 6/2/15, 2:13 PM, Eric W. Biederman wrote:
>> So I just stopped and looked at what is happening.  When you originally
>> reported this you said (or at least I understood) that rtm_scope was not
>> being set in iproute.  I assumed that meant it was not being touched
>> and it was taking a default value of zero (or else it was possibly
>> floating).  Having looked neither is true.  iproute sets rtm_scope
>> to RT_SCOPE_NOWHERE during delete deliberately to act as a wild card.
>>
>> In the kernel in other protocols currently ipv4 treats RT_SCOPE_NOWHERE
>> as a wild card during delete, decnet treats RT_SCOPE_NOWHERE as a wild
>> card during delete, the remaining protocols (ipv6, phonet, and can) that
>> implement RTM_DELROUTE do not look at rtm_scope at all.  Further ipv6
>> and phonet set rtm_scope to RT_SCOPE_UNIVERSE when dumped.
>>
>> Which says to me that we have semantics in the kernel that no one has
>> let userspace know about, and that scares me when there is a
>> misunderstanding between the kernel and userspace about what fields
>> mean.  That inevitabily leads to bugs.  The kind of bugs that I have
>> to create security fixes for recently.
>>
>> So I really think we should fix this in userspace so that that someone
>> reading iproute will have a chance at knowing that this scopes do not
>> exist in ipv6 and mpls and that scope logic is just noise in those
>> cases.
> ack,  i did start with handling both type and scope
> in iproute2. I misunderstood you when you said you did not care
> abt the scope in earlier comments. so i made the kernel not care abt the
> scope. :) but only handled type in 'iproute2' in v2.  now its clear. I do have a
> similar patch like below.
> sorry abt the iterations. I will respin (If you prefer to post your below patch
> yourself, pls do. I am ok either way. Thanks.

I don't have enough energy to follow through with more than review
today.

Eric
