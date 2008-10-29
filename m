From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Wed, 29 Oct 2008 11:33:25 +0100
Message-ID: <49083BF5.5090606@trash.net>
References: <20081029102356.GA6165@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62243 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbYJ2Kd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 06:33:28 -0400
In-Reply-To: <20081029102356.GA6165@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 29-10-2008 10:19, Patrick McHardy wrote:
>> Changli Gao wrote:
>>> On Wed, Oct 29, 2008 at 5:01 PM, Patrick McHardy <kaber@trash.net> wrote:
>>>> The estimators needs
>>>> this since they're estimating the arrival rate.
>>>>
>>>>
>>> I do not agree with you. TC is only for sending packets. Why does its
>>> estimator estimating the arrival rate?
>> I suppose because they were intended for policing.
> 
> On the other hand, it seems with shaping qdiscs they are more useful
> to query dequeue rates.

Only for purely informational purposes, for policing you'd want to
use arrival rates. Since there are no users of estimators in the kernel
besides policers (which use seperate ones), the point is not terribly
important. But I would prefer to not start introducing (or extending)
inconsistencies among qdisc implementations here, that will only make
it harder in case someone finally implements something useful with
estimators.
