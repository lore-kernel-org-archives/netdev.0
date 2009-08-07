From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 06 Aug 2009 21:22:42 -0700
Message-ID: <m1k51gqmlp.fsf@fess.ebiederm.org>
References: <20090806143959.GA29323@gondor.apana.org.au>
	<m1zladhtoh.fsf@fess.ebiederm.org>
	<20090807002243.GB1566@gondor.apana.org.au>
	<20090806.204032.39020854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, paul.moore@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52969 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbZHGEWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 00:22:46 -0400
In-Reply-To: <20090806.204032.39020854.davem@davemloft.net> (David Miller's message of "Thu\, 06 Aug 2009 20\:40\:32 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 7 Aug 2009 10:22:44 +1000
>
>> tun: Extend RTNL lock coverage over whole ioctl
>> 
>> As it is, parts of the ioctl runs under the RTNL and parts of
>> it do not.  The unlocked section is still protected by the BKL,
>> but there can be subtle races.  For example, Eric Biederman and
>> Paul Moore observed that if two threads tried to create two tun
>> devices on the same file descriptor, then unexpected results
>> may occur.
>> 
>> As there isn't anything in the ioctl that is expected to sleep
>> indefinitely, we can prevent this from occurring by extending
>> the RTNL lock coverage.
>> 
>> This also allows to get rid of the BKL.
>> 
>> Finally, I changed tun_get_iff to take a tun device in order to
>> avoid calling tun_put which would dead-lockt as it also tries to
>> take the RTNL lock.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> This looks good after a quick audit, Eric what say you?

Looks good to me.

Eric



