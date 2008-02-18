From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 19 Feb 2008 00:01:54 +0100
Message-ID: <20080218230154.GB6373@ami.dom.local>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:38172 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbYBRW4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 17:56:34 -0500
Received: by ug-out-1314.google.com with SMTP id z38so436032ugc.16
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2008 14:56:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47BA0214.40703@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2008 at 10:09:24PM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
>> Hi,
>>
>> It seems, this nice report is still uncomplete: could you check if
>> there could have been something more yet?
>
> Unfortunately the ISP's syslog stops. But I've been able to borrow two
> Quad Xeon boxes and have reproduced the problem.
>
> Here's a new version of the patch. The patch avoids disabling irqs and
> fixes the sk_dst_get() usage that DaveM mentioned. But even with this
> patch, lockdep still complains if hundreds of ppp sessions are inserted
> into a tunnel as rapidly as possible (lockdep trace is below). I can
> stop these errors by wrapping the call to ppp_input() in
> pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is a
> better fix?

Hmm... This is a really long report and quite a bit different from
the previous one. I need some time for this. BTW: you sent before a
lockdep report with hlist_lock problem. I think this could be fixed
in some independent patch to make this all more readable. Are all
the other changes in this current patch only because of this or
previous lockdep report or for some other reasons (or reports) yet?

Regards,
Jarek P.
