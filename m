From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 22:13:49 +0200
Message-ID: <d2cd1065faf8a13040e8a2405c363aa1@kernel.crashing.org>
References: <46BCC26B.6080600@redhat.com> <46BB46B2.60808@redhat.com> <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com> <7680.1186822071@redhat.com> <46BFFDBD.6080804@redhat.com> <46C140DD.3060509@yahoo.com.au> <2cbda24e96a49c3ab7cf7039c515f9fc@kernel.crashing.org> <20070815191829.GJ9645@linux.vnet.ibm.com> <369924c4b3132a4b06258b7ac81b1006@kernel.crashing.org> <20070815195915.GL9645@linux.vnet.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com,
	David Howells <dhowells@redhat.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60926 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759521AbXHOUQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 16:16:25 -0400
In-Reply-To: <20070815195915.GL9645@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> Well if there is only one memory location involved, then smp_rmb()
>>>>> isn't
>>>>> going to really do anything anyway, so it would be incorrect to use
>>>>> it.
>>>>
>>>> rmb() orders *any* two reads; that includes two reads from the same
>>>> location.
>>>
>>> If the two reads are to the same location, all CPUs I am aware of
>>> will maintain the ordering without need for a memory barrier.
>>
>> That's true of course, although there is no real guarantee for that.
>
> A CPU that did not provide this property ("cache coherence") would be
> most emphatically reviled.

That doesn't have anything to do with coherency as far as I can see.

It's just about the order in which a CPU (speculatively) performs the 
loads
(which isn't necessarily the same as the order in which it executes the
corresponding instructions, even).

> So we are pretty safe assuming that CPUs
> will provide it.

Yeah, pretty safe.  I just don't like undocumented assumptions :-)


Segher

