From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: x86: fix JIT address randomization
Date: Tue, 13 May 2014 17:38:28 -0400 (EDT)
Message-ID: <20140513.173828.1128380962164004400.davem@davemloft.net>
References: <1400012629.7973.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuxLbDpkxJ4fORRdsJ36vBiidBwA0SVAwvmDHEpPmhTA2Q@mail.gmail.com>
	<53728E97.6030400@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, eric.dumazet@gmail.com, edumazet@google.com,
	dborkman@redhat.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org
To: hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbaEMVid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 17:38:33 -0400
In-Reply-To: <53728E97.6030400@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 13 May 2014 14:28:55 -0700

> On 05/13/2014 01:34 PM, Alexei Starovoitov wrote:
>>>
>>> The argument of not having code ending on (or being very close of) page
>>> boundary seems orthogonal to this bug fix.
>> 
>> Gotta pick some number... page/2 seems good enough to have
>> large range for prandom() to choose and better performance.
>> Another alternative is to do min(…, PAGE_SIZE - sizeof(*header)),
>> but that is harder to understand.
>> 
> 
> The latter is correct by construction, and thus doesn't end up with the
> question "what is going on here" or has hidden failure conditions.

Agreed.

>> Also just realized that I miscalculated the breaking point:
>> "If prandom_u32() % hole selects a number >= 4096, then kernel will crash"
>> it should read: "… >= 4092 ..."
>> since sizeof(*header) needs to be accounted for.
> 
> No, it should read PAGE_SIZE - sizeof(*header) if anything.

Also agreed.
