From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/13] SCTP: Enable netns
Date: Mon, 06 Aug 2012 16:06:02 -0700
Message-ID: <87txwfipt1.fsf@xmission.com>
References: <87mx27rig7.fsf@xmission.com> <50201928.2030802@gmail.com>
	<874noflrzd.fsf@xmission.com>
	<20120806.134737.1358773847818872075.davem@davemloft.net>
	<502039A8.7080807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, jan.ariyasu@gmail.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jan.ariyasu@hp.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <502039A8.7080807@gmail.com> (Vlad Yasevich's message of "Mon, 06
	Aug 2012 17:39:52 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich <vyasevich@gmail.com> writes:

> On 08/06/2012 04:47 PM, David Miller wrote:
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Mon, 06 Aug 2012 12:50:46 -0700
>>
>>> Vlad Yasevich <vyasevich@gmail.com> writes:
>>>
>>>
>>>> Hi Eric
>>>>
>>>> Associations are looked up by ports, but then verifyed by addresses.
>>>> Also, associations belong to sockets and simply validating the socket
>>>> namespace should be sufficient.
>>>
>>> True.  Your set of patches isn't quite as likely to malfunction as it
>>> looked at first glance.  It requires address reuse which happens accross
>>> namespaces but not too frequently.
>>>
>>> As for validating the socket namespace I agree that is the fix and my
>>> patchset winds up doing it.
>>
>> FWIW I much prefer Eric's patch set, it was so significantly easier to
>> read and validate than Jan's.
>>
>
> Yes, but Eric's patch set is missing a very significant piece which is per-net
> sctp tunables/globals.  I think adding that piece in will introduce some of the
> complexities of Jan's patch.

And Jan's patchset is missing the per net snmp counters, as well
as the per net checks when looking in the hash tables.  Things that look
like fairly fundamental correctness issues.

No offense but I think Jan's patchset has minor but significant
structural flaws and correctness issues that would require the patchset
to be respun, after review even if my patches did not exist.

The poor movement of variables from their global context into the per
net context is one of those problems.

The fact that after Jan's patchset all of the tunables despite being
made per net remain in struct sctp_globals and sit their unused is a
recipe for confusion.

So I think the simplest path forward would be to merge my patches, and
then merge Jan's tunable work after she has had a chance to rebase it.

> Also, I noticed that Eric went the route of placing sctp netns into struct net,
> but Jan used a generic pointer.  Which one should be used? Is there some
> guidance?

Placing things directly in struct net is more efficient.  Using net
generic is more convenient for development as using net generic does not
require a kernel recompile.

For minor things and especially where it does not have an impact on
performance net generic is the way to go.

It looked to me that sctp was fundamental enough and had enough
important data structures on the hot path that placing the variables
in struct net directly seemed sensible.

Eric
