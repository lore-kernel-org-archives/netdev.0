From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] sctp: chunkmap size is too large
Date: Mon, 09 Feb 2009 14:50:19 +0100
Message-ID: <4990349B.30700@trash.net>
References: <4983200B.2080707@6wind.com> <20090201.011427.38305360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: olivier.matz@6wind.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, kaber@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55210 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727AbZBINuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 08:50:22 -0500
In-Reply-To: <20090201.011427.38305360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Olivier MATZ <olivier.matz@6wind.com>
> Date: Fri, 30 Jan 2009 16:43:07 +0100
> 
>> I think that the chunkmap field in struct xt_sctp_info is
>> too large: we have 256 chunk types and it's a bitfield,
>> so the table should be 256 bits (8 uint32_t) instead
>> of 64 uint32_t.
>>
>> I updated the size of the table, and I did some cosmetic
>> changes in SCTP_CHUNKMAP_* macros (use a mask instead of
>> a modulo).
>>
>>   netfilter/xt_sctp.h       |   30 ++++++++++++++++--------------
>>   netfilter_ipv4/ipt_sctp.h |   30 ++++++++++++++++--------------
>>   2 files changed, 32 insertions(+), 28 deletions(-)
>>
>> Can someone have a look at it ? Please CC me for any replies
>> as I'm not on the list.
> 
> Patrick, I assume you got this?

Sorry for the delay. As Jan already noticed, it changes the ABI,
so we change it without adding a new revision. And I don't think
a few bytes of memory savings justify that.

