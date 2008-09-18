From: "Julius Volz" <juliusv@google.com>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Thu, 18 Sep 2008 22:05:19 +0200
Message-ID: <f4845fc0809181305s4221efe6r1a6614a56a28cfa8@mail.gmail.com>
References: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com>
	 <48D14E6D.4020407@redhat.com> <20080918042436.GB32516@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Chris Snook" <csnook@redhat.com>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60997 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929AbYIRUFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 16:05:25 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id m8IK5M56004568
	for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 21:05:22 +0100
Received: from ey-out-2122.google.com (eyd9.prod.google.com [10.208.4.9])
	by wpaz17.hot.corp.google.com with ESMTP id m8IK5KCc023870
	for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 13:05:21 -0700
Received: by ey-out-2122.google.com with SMTP id 9so30547eyd.63
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 13:05:20 -0700 (PDT)
In-Reply-To: <20080918042436.GB32516@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 6:24 AM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Sep 17, 2008 at 02:37:33PM -0400, Chris Snook wrote:
>> Julius Volz wrote:
>>> Since IPVS now does partial IPv6, should we finally move it from
>>> "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
>>> long time ago, but that was before any of the actual v6 features, so
>>> there was probably no interest.
>>
>> Whatever the netfilter people want is fine with me.
>>
>>> Also, the tunables in /proc/sys/net/ipv4/vs/... apply to both v4 and
>>> v6. Should we just duplicate them into /proc/sys/net/ipv6/vs? Or will
>>> people be confused that setting a value in one directory changes the
>>> value in the other and affects both IP versions?
>>
>> If we do any duplication of sysctl tunables under net.ipv4 into net.ipv6,
>> we need to follow the same policy for all of them.  Since the tcp
>> tunables in net.ipv4 are among the most documented and used, and have
>> been for a decade, we need to be conservative with that.  Having two
>> different writable tunables for the same variable is certain to confuse.
>> Having read-only aliases under net.ipv6 wouldn't terrify me, but the last
>> time I went to do tcp tuning, and saw that the tunables in net.ipv4
>> weren't duplicated under net.ipv6, it was obvious what was going on at
>> first glance, without needing to do an ls -l to figure out what was going
>> on.  People who prefer to use sysctl rather than manually tweaking
>> pseudofiles might not notice the permissions right away.  By the
>> principle of least confusion, I think omitting them entirely is probably
>> the way to go.
>
> If thats a standard practice, than that sounds reasonable to me.

Ok, so no change for now.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
