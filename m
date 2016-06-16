From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Thu, 16 Jun 2016 14:18:05 -0700 (PDT)
Message-ID: <20160616.141805.201276959937562482.davem@davemloft.net>
References: <6b8ad88f-db0b-3a88-197d-ed7278783bfc@cumulusnetworks.com>
	<20160615.124800.889153492414820174.davem@davemloft.net>
	<2c081044-0861-8a84-f4ae-88c60c4ddc67@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org, ja@ssi.bg
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754421AbcFPVSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 17:18:07 -0400
In-Reply-To: <2c081044-0861-8a84-f4ae-88c60c4ddc67@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 15 Jun 2016 14:29:28 -0600

> On 6/15/16 1:48 PM, David Miller wrote:
>> But if people don't use the helpers, and initialize flow structures
>> on their own, yeah that defeats the whole mechanism and things will
>> seem harder and "unhelpful".
> 
> That's my point -- the flow struct does not have a consistent
> initializer. There have been a number of bug patches over the past
> year like 4cfc86f3dae6 to handle uninitialized elements. My suggestion
> here is the same as 4cfc86f3dae6 which is to initialize the flow when
> it is declared.
> 
> Consider the recent change from Hannes for 38b7097b55b6. fl6 can be
> initialized when it is declared with a bit of straightforward
> refactoring -- icmp6_send has an easy split into 2.
> 
> Seems like that is a more robust long term solution considering the
> various init use cases.

The danger with initializers is it puts the burdon all over the tree.

So now there are many places that need to be audited when a new
element is added.

So from my perspective, the bug is that the code in question did
things by hand rather than using the helper function.

If everyone used the flow initializer helpers, the compiler would
tell us every place that needs to be fixed up.

By doing initializers inline, this process of discovery is more
difficult and error prone.
