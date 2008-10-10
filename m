From: Patrick McHardy <kaber@trash.net>
Subject: Re: deadlocks if use htb
Date: Fri, 10 Oct 2008 14:32:50 +0200
Message-ID: <48EF4B72.8080305@trash.net>
References: <20081010075640.GA5204@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org,
	Denys <denys@visp.net.lb>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53299 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbYJJMcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 08:32:55 -0400
In-Reply-To: <20081010075640.GA5204@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 10-10-2008 07:44, Badalian Vyacheslav wrote:
>> Hello all!
> 
> Hello Slavon,
> 
>> Please look to if you have time:
>> http://bugzilla.kernel.org/show_bug.cgi?id=11718
>>
>> We have deadlocks at few PC one times in week.
>> I can test any patches to detect and fix problem.
>> Now i test 2.6.27-rc kernel at one PC.
> 
> A similar bug was reported by Denys Fedoryshchenko but it wasn't fully
> diagnosed. Anyway it looks like hardware dependent. The patch below
> can sometimes help. 2.6.27 may have this fixed too (some other way).

I doubt its hardware related, whats happening is that the hrtimer
insertion gets into an endless loop because the rb tree (or node)
apparently has a loop. I went through the qdiscs' use of hrtimers
again, but can't spot any error there.

Denys, did your systems also have CONFIG_HIGH_RES_TIMERS=n?
