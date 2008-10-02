From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Thu, 2 Oct 2008 01:01:01 -0400
Message-ID: <20081002010101.6f0a1fa5.billfink@mindspring.com>
References: <48E141F3.9000903@cosmosbay.com>
	<20080929223801.GA3157@hmsreliant.think-freely.org>
	<48E1C104.2080801@cosmosbay.com>
	<20080930.071023.07946874.davem@davemloft.net>
	<48E25F02.8030303@cosmosbay.com>
	<20081001180846.GB3566@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:49213 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751547AbYJBFP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 01:15:28 -0400
In-Reply-To: <20081001180846.GB3566@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2008, Neil Horman wrote:

> Hey all-
> 	Since Eric mentioned the use of statistical analysis to determine if
> hash chains were growing improperly, I thought I would take a stab at such an
> approach.  I'm no statistics expert, but it would seem to me that simply
> computing the standard deviation of all the non-zero chain lengths would give a
> good guide point to determine if we needed to invalidate our hash table.  I've
> written the below implementation.  I've not tested it (I'll be doing that here
> shortly for the next few days), but I wanted to post it to get feedback from you
> all on the subject.  The highlights are:
> 
> 1) We add a counter to rt_hash_bucket structure to track the length of each
> individual chain.  I realize this is sub-optimal, as it adds potentially lots of
> memory to hash table as a whole (4 bytes * number of hash buckets).  I'm afraid
> I've not come up with a better way to track that yet.  We also track the total
> number of route entries and the number of non-zero length chains.  Lastly we
> also maintain a global maximum chain length which defines the longest chain we
> will tolerate in the route table.  This patch defines it as the mean chain
> length plus one standard deviation.

I believe the general rule of thumb for something like this is at
least two standard deviations.  For a normal distribution, one standard
deviation covers about 68 % of the sample universe, while two standard
deviations covers about 95 % (three standard deviations covers 99.73 %).
See the Wikipedia entry:

	http://en.wikipedia.org/wiki/Standard_deviation

						-Bill
