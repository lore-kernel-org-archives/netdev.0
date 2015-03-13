From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 4/4] netfilter: Fix format string of nfnetlink_queue proc
 file
Date: Fri, 13 Mar 2015 15:22:07 +0100
Message-ID: <5502F28F.9050601@nod.at>
References: <1426246276-15839-1-git-send-email-richard@nod.at> <1426246276-15839-5-git-send-email-richard@nod.at> <20150313121539.GA14488@salvia> <5502E99A.2060901@nod.at> <20150313135329.GA6054@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:65278 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173AbbCMOWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 10:22:13 -0400
In-Reply-To: <20150313135329.GA6054@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 13.03.2015 um 14:53 schrieb Pablo Neira Ayuso:
> On Fri, Mar 13, 2015 at 02:43:54PM +0100, Richard Weinberger wrote:
>> Am 13.03.2015 um 13:15 schrieb Pablo Neira Ayuso:
>>> On Fri, Mar 13, 2015 at 12:31:16PM +0100, Richard Weinberger wrote:
>>>> The printed values are all of type unsigned integer, therefore use
>>>> %u instead of %d. Otherwise an user can face negative values.
>>>>
>>>> Fixes:
>>>> $ cat /proc/net/netfilter/nfnetlink_queue
>>>>     0  29508   278 2 65531     0 2004213241 -2129885586  1
>>>>     1 -27747     0 2 65531     0     0        0  1
>>>>     2 -27748     0 2 65531     0     0        0  1
>>>
>>> I guess you want to access stats on dropped packets.
>>
>> Correct. :)
>>
>>> I prefer if you extend nfnetlink_queue to provide statistics through
>>> nfnetlink_queue, so you don't have to manually parse this text-based
>>> /proc entry and we can deprecate this interface. That shouldn't have
>>> been there in first place.
>>
>> You mean statistics via netlink attributes? I can add that!
> 
> Add a new NFQNL_CFG_CMD_STATS command to request the statistics. If
> NLM_F_DUMP is set, then we'll basically provide the full list of
> instances. Otherwise, in case you want to retrieve stats for a
> specific netlink socket, you can use the netlink portID as index.
> And you'll have to add attributes for this new command, yes.

This was my plan. Thanks for the pointer!

>> But I think we should also fix the format string of the proc file
>> as the fix is easy and non-intrusive.
> 
> Unfortunately we don't know how many people are relying on that
> output, I prefer to remain conservative and provide a proper netlink
> interface for this.

I understand your concerns but an application which is able to parse positive
and negative numbers can also parse pure positives.
Just made a small test application, glibc's %d in sscanf() can also deal with UINT_MAX.
And I don't expect that applications to check whether the returned values from
/proc/net/netfilter/nfnetlink_queue are between INT_MIN and INT_MAX.

That said, I'd have assumed that an user would report negative values as plain kernel bug.

Thanks,
//richard
