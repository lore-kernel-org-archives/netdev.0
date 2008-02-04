From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Mon, 04 Feb 2008 18:48:30 +0100
Message-ID: <47A74FEE.6080103@trash.net>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34150 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898AbYBDRsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 12:48:41 -0500
In-Reply-To: <47A4FB81.80700@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corey Hickey wrote:
> Patrick McHardy wrote:
>> These patches add support for external classifiers to SFQ and add a
>> new "flow" classifier, which can do hashing based on user-specified
>> keys or deterministic mapping of keys to classes. Additionally there
>> is a patch to make the SFQ queues visisble as classes to verify that
>> the hash is indeed doing something useful and a patch to consifiy
>> struct tcf_ext_map, which I had queued in the same tree.
> 
> Excellent! I'm glad this is applied. I'm having trouble figuring out how
> it works, though. As a test, I'm trying to set up SFQ equivalent to
> ESFQ's "hash dst". Here's what I do, and this is what I get:
> 
> ------------------------------------------------------------------------
> # ./tc qdisc add dev eth0 root handle 1: sfq
> # ./tc filter add dev eth0 parent 1: flow hash keys dst
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
> ------------------------------------------------------------------------
> 
> I've tried a few different keys with the same results. I don't know what
> I'm doing wrong, or even where to start figuring it out. Can you point
> me in the right direction?


You're missing protocol, handle etc. Try something like this:

tc filter add dev eth0 protocol ip pref 1 parent 1: handle 1 \ 

         flow hash keys dst divisor 1024

