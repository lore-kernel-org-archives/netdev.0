From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 06 Aug 2009 03:21:41 -0700
Message-ID: <m1hbwlkzt6.fsf@fess.ebiederm.org>
References: <20090803161242.12947.14620.stgit@flek.lan>
	<m1ljlyvn9a.fsf@fess.ebiederm.org>
	<200908051738.43134.paul.moore@hp.com>
	<20090806101044.GA26589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47636 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbZHFKVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 06:21:45 -0400
In-Reply-To: <20090806101044.GA26589@gondor.apana.org.au> (Herbert Xu's message of "Thu\, 6 Aug 2009 20\:10\:44 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Wed, Aug 05, 2009 at 05:38:42PM -0400, Paul Moore wrote:
>>
>> My concern is that I believe that if the kernel fails at an operation it 
>> should do all it can to unwind any actions it took in the course of attempting 
>> to perform the requested operation.  Leaving a TUN device around in the case 
>> of a tun_attach() failure seems like the kernel is being lazy, sure a user can 
>> cleanup the device but why should they have to?
>
> That particular tun_attach should never fail.  Perhaps you can
> just add a WARN_ON.

Two threads one file descriptor.  Both simultaneously attempt to 
attach to a tun device.  One will fail, the other succeed.

At least that is how I read the locking.

Eric
