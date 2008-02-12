From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 12 Feb 2008 07:19:22 +0000
Message-ID: <20080212071922.GA2582@ff.dom.local>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com> <47B09A90.7040508@gmail.com> <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:53980 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756861AbYBLHMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 02:12:09 -0500
Received: by ug-out-1314.google.com with SMTP id z38so438471ugc.16
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 23:12:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47B0DD1E.5000608@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 11:41:18PM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
>> On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
>> ...
>>> Below is example output from lockdep. The oops is reproducible when   
>>> creating/deleting lots of sessions while passing data. The lock is 
>>> being  acquired for read and write in softirq contexts.
>>>
>>> Is there a better way to fix this?
>>>
>>> =================================
>>> [ INFO: inconsistent lock state ]
>>> 2.6.24-core2 #1
>>> ---------------------------------
>>> inconsistent {in-softirq-R} -> {softirq-on-W} usage.
>>> openl2tpd/3215 [HC0[0]:SC0[0]:HE1:SE1] takes:
>>>   (&tunnel->hlist_lock){---?}, at: [<f8eea157>]
>>> pppol2tp_connect+0x517/0x6d0 [pppol2tp]
>>> {in-softirq-R} state was registered at:
>>
>> IMHO, according to this, disabling bh should be enough. And if it's
>> like in this report: only read_lock is taken from softirqs, then this
>> should be necessary to change only all write_locks to write_lock_bh
>> (of course unless somewhere bhs are disabled already). Unless I miss
>> something?!
>
> I thought so too. I tried _bh locks first and the problem still  
> occurred. Maybe I'll try it again in case I messed something up.

If there are any new lockdep warnings I'd be interested to have
a look. (BTW, with irqs disabling such ISP would probably get
considerable drop in performance?)

Regards,
Jarek P.
