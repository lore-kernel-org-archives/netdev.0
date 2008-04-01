From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Tue, 01 Apr 2008 14:39:17 +0200
Message-ID: <47F22CF5.4080806@trash.net>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net> <47EED247.50801@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60861 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbYDAMjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 08:39:21 -0400
In-Reply-To: <47EED247.50801@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Furniss wrote:
> Patrick McHardy wrote:
> 
>> tc filter add dev eth0 protocol ip pref 1 parent 1: handle 1 \
>>         flow hash keys dst divisor 1024
>>
> 
> I've been trying to incorporate this into my own setup but haven't got 
> very far :-)
> 
> I don't even know if it's possible to attach to htb subclasses and 
> expect it to work. If it is do you have an example (is this what 
> baseclass is for?).
> 
> I can attach to a filter to other than parent 1:0 OK but it doesn't do 
> anything.
> 
> I have also tried incorporating flow into the 1:0 filters that filter to 
> the htb subclasses that have the sfqs attached to them, but can't get 
> ematch to work - but then I have never been able to get ematch to work. 
> I can't find any examples. All I need if this is the way to go is to 
> match on mark and match on anything.
> 
> Is this possible and if so, do you have/know of any examples?

What exactly are you trying to do? If you attach the classifier
to HTB, it will classify to HTB classes. I guess you actually
want to use it for SFQ, which should work with:

tc qdisc add ... handle x: sfq
tc filter add parent x: protocol all flow ...

