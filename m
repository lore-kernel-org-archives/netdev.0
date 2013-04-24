From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCHv2 net-next] net: fix address check in rtnl_fdb_del
Date: Tue, 23 Apr 2013 20:29:29 -0400
Message-ID: <51772769.6080306@redhat.com>
References: <1366751123-10143-1-git-send-email-vyasevic@redhat.com> <20130423.183037.831300005006610868.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755394Ab3DXAb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 20:31:57 -0400
In-Reply-To: <20130423.183037.831300005006610868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2013 06:30 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Tue, 23 Apr 2013 17:05:23 -0400
>
>> Commit 6681712d67eef14c4ce793561c3231659153a320
>> 	vxlan: generalize forwarding tables
>>
>> relaxed the address checks in rtnl_fdb_del() to use is_zero_ether_addr().
>> This allows users to add multicast addresses using the fdb API.  However,
>> the check in rtnl_fdb_del() still uses a more strict
>> is_valid_ether_addr() which rejects multicast addresses.  Thus it
>> is possible to add an fdb that can not be later removed.
>> Relax the check in rtnl_fdb_del() as well.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>
> I don't think you were able to actually test this patch in the
> amount of time between when the bug in your initial version was
> shown to you and when you posted this new version.
>
> If you indeed didn't test this patch, I really don't think that's
> acceptable, to be honest with you.
>

I actually did test this patch and found the issue in the testing of the
bridging changes I was working on.  It just that I goofed the stand 
alone fix that I thought might warrant a separate submission while I
run more tests on the bridging code.

-vlad
