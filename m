From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Thu, 30 Oct 2008 10:21:25 +0100
Message-ID: <49097C95.2040806@trash.net>
References: <20081029102356.GA6165@ff.dom.local> <49083BF5.5090606@trash.net>	 <412e6f7f0810291803j3858cd2fq373a9c4f49664825@mail.gmail.com>	 <49095E3E.70705@trash.net> <412e6f7f0810300211v53872b1bid2f9c8a1d89cde82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56120 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbYJ3JV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 05:21:29 -0400
In-Reply-To: <412e6f7f0810300211v53872b1bid2f9c8a1d89cde82@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Thu, Oct 30, 2008 at 3:11 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Independant of this statistics bug, according to your description
>> you want to measure departure rates (otherwise the measured rates
>> can't really be compared to the limit) and the current counters are
>> not really suitable for this since they count arriving packets.
>> So the only way to properly do this is to add seperate counters that
>> account for departing packets. I think this would be a good addition
>> since we've always been advocating to do this stuff in userspace,
>> but it would need some thought on how to minimize the impact for
>> people not needing it.
>>
>>
> In fact, only the counters of the leaf classes represent arriving
> rates, but the others represent departing rates. Is it right? Or does
> it need to be fixed?

Its not correct, but I wouldn't fix it at this time unless you can
suggest a good way that doesn't require to walk the entire hierarchy
during ->enqueue() just for the class counters.


