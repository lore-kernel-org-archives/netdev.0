From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 15:39:39 +0100
Message-ID: <49C107AB.1030003@trash.net>
References: <20090318112937.675BF13A4B0@koiott.tartu-labor> <Pine.LNX.4.64.0903181332140.13734@ondatra.tartu-labor>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43119 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757169AbZCROjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 10:39:44 -0400
In-Reply-To: <Pine.LNX.4.64.0903181332140.13734@ondatra.tartu-labor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meelis Roos wrote:
>> Data is represented in a generic way inside the kernel and the
>> operations are defined on the generic data representations, meaning
>> its possible to use any matching feature (ranges, masks, set lookups
>> etc.) with any kind of data. Semantic validation of the operation is
>> performed in userspace, the kernel doesn't care as long as the
>> operation doesn't potentially harm the kernel.
> 
> This sounds like a "script" downloaded to kernel and interpreted during 
> each packet match. This toubles me some - doesn't this use more memory 
> accesses to achieve the same work that was done in precompiled code before?

What makes you think your current ruleset is precompiled?

> Have you measured the fastpath performance of kernel matching of 
> real-life rulesets, compared to iptables?

Yes, but its not a 1:1 comparison. By inlining common operations
(small comparisions, small alignned data loads) in the evaluation
function, costs for a "normal" rule become comparable to iptables.
As soon as you start actually using some of the new stuff, the
comparison doesn't hold anymore. A set, even using rbtrees, which
have a huge overhead in this case, is *a lot* faster than using the
equivalent linear classification rules beginning with a quite small
number. Similar, if you replace 200 rules
"-m realm --realm X --CONNMARK --set-mark X" by a single one, it
will obviously be faster.

On top it has far smaller code and less memory usage as soon as
you have more than one CPU, its lockless, no default counters,
no overhead for unused chains, etc etc.

When the time has come, I will of course post benchmarks.

