From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ipmr:  Fix struct mfcctl to be independent of MAXVIFS v2
Date: Tue, 06 Apr 2010 10:23:08 -0700
Message-ID: <m14ojo7awz.fsf@fess.ebiederm.org>
References: <m1mxxgbwtl.fsf@fess.ebiederm.org>
	<m1eiis8uc6.fsf@fess.ebiederm.org> <4BBB67FE.6020209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Ilia K <mail4ilia@gmail.com>, Tom Goff <thomas.goff@boeing.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39338 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab0DFRXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 13:23:14 -0400
In-Reply-To: <4BBB67FE.6020209@candelatech.com> (Ben Greear's message of "Tue\, 06 Apr 2010 09\:57\:34 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> On 04/06/2010 08:38 AM, Eric W. Biederman wrote:
>>
>> Right now if you recompile the kernel increasing MAXVIFS
>> to support more VIFS users of the MRT_ADD_VIF and MRT_DEL_VIF
>> will break because the ABI changed.
>>
>> My goal is an API that works with just a recompile of existing
>> applications, and an ABI that continues to work for old
>> applications.
>>
>> The unused/dead fields at the end of struct mfcctl make this
>> exercise more difficult than it should be.
>>
>> - Rename the existing struct mfcctl mfcctl_old.
>> - Define a new and larger struct mfcctl that we can detect
>>    by size.
>>
>>    The new and larger struct mfcctl won't have trailing garbage
>>    fields so we can accept anything of that size or larger,
>>    and simply ignore the entries that are above MAXVIFS.
>>
>> My new struct mfcctl is now 128 bytes which is noticeable on
>> the stack but should still be small enough not to cause problems.
>>
>> v2:  Rework the support larger arrays so that most/all? existing
>>     applications can simply be recompiled and work with a larger
>>     maximum number of VIFS.
>
> If we're going to change the ABI, can we not support an arbitrary
> number of VIFS instead of just a larger fixed maximum?

The ABI as I have specified should work for any larger structure than
I have specified.  But like select many applications will limit themselves
to use the definition of struct mfcctl that is passed to them.

Eric
