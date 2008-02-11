From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 23:41:18 +0000
Message-ID: <47B0DD1E.5000608@katalix.com>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com> <47B09A90.7040508@gmail.com> <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:59694 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670AbYBKXlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 18:41:21 -0500
In-Reply-To: <20080211224924.GA2863@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
> ...
>> Below is example output from lockdep. The oops is reproducible when  
>> creating/deleting lots of sessions while passing data. The lock is being  
>> acquired for read and write in softirq contexts.
>>
>> Is there a better way to fix this?
>>
>> =================================
>> [ INFO: inconsistent lock state ]
>> 2.6.24-core2 #1
>> ---------------------------------
>> inconsistent {in-softirq-R} -> {softirq-on-W} usage.
>> openl2tpd/3215 [HC0[0]:SC0[0]:HE1:SE1] takes:
>>   (&tunnel->hlist_lock){---?}, at: [<f8eea157>]
>> pppol2tp_connect+0x517/0x6d0 [pppol2tp]
>> {in-softirq-R} state was registered at:
> 
> IMHO, according to this, disabling bh should be enough. And if it's
> like in this report: only read_lock is taken from softirqs, then this
> should be necessary to change only all write_locks to write_lock_bh
> (of course unless somewhere bhs are disabled already). Unless I miss
> something?!

I thought so too. I tried _bh locks first and the problem still 
occurred. Maybe I'll try it again in case I messed something up.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

