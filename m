From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 19 Feb 2008 09:09:38 +0000
Message-ID: <47BA9CD2.5030507@katalix.com>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080218230154.GB6373@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37519 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760616AbYBSJJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 04:09:44 -0500
In-Reply-To: <20080218230154.GB6373@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Feb 18, 2008 at 10:09:24PM +0000, James Chapman wrote:
>> Jarek Poplawski wrote:
>>> Hi,
>>>
>>> It seems, this nice report is still uncomplete: could you check if
>>> there could have been something more yet?
>> Unfortunately the ISP's syslog stops. But I've been able to borrow two
>> Quad Xeon boxes and have reproduced the problem.
>>
>> Here's a new version of the patch. The patch avoids disabling irqs and
>> fixes the sk_dst_get() usage that DaveM mentioned. But even with this
>> patch, lockdep still complains if hundreds of ppp sessions are inserted
>> into a tunnel as rapidly as possible (lockdep trace is below). I can
>> stop these errors by wrapping the call to ppp_input() in
>> pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is a
>> better fix?
> 
> Hmm... This is a really long report and quite a bit different from
> the previous one. I need some time for this. BTW: you sent before a
> lockdep report with hlist_lock problem. I think this could be fixed
> in some independent patch to make this all more readable. Are all
> the other changes in this current patch only because of this or
> previous lockdep report or for some other reasons (or reports) yet?

As I mentioned in my reply to davem, modifying the pppol2tp driver as 
described in the patch I sent made the original lockdep problems go away.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

