From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Tue, 1 Dec 2015 13:37:20 -0500
Message-ID: <20151201183720.GE21252@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-crypto@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30784 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740AbbLAShZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 13:37:25 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/01/15 10:18), Tom Herbert wrote:
> >      8.5-9.5 Gbps clear traffic, TSO disabled, so GSO, GRO is in effect
> >      3-4 Gbps clear traffic, with both TSO/GSO disabled
> >      1.8-2 Gbps for esp-null.
> 
> Are you losing checksum offload also?

I tried with both checksum offload on and off.
For the GSO case, doesnt make a huge difference to perf. 
For my patch, I disable h/w cksum offload, so that I can leverage
from the existing cksum calculations in the existing GSO code. That helps
a bit (goes from 3 Gbps -> 3.2 Gbps, but I need a 2x jump here)


> Thanks for the nice data! We could certainly implement GRO/GSO for
> esp-null to get your numbers up but I don't think that would be very
> useful to anyone. Do you have the performance numbers using real
> encryption?

I was using esp-null merely to not have the crypto itself perturb
the numbers (i.e., just focus on the s/w overhead for now), but here
are the numbers for the stock linux kernel stack
                Gbps  peak cpu util
esp-null         1.8   71%
aes-gcm-c-256    1.6   79%
aes-ccm-a-128    0.7   96%

That trend made me think that if we can get esp-null to be as close
as possible to GSO/GRO, the rest will follow closely behind.

So is my patch in the right direction? Anything obvious I am missing?
I'd like to budge that number beyond 3 Gbps :-)

--Sowmini
