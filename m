From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 4/4] bonding: Fix some RTNL taking
Date: Thu, 17 Jan 2008 12:46:55 +0100
Message-ID: <20080117114655.GC1710@ff.dom.local>
References: <20080116124450.GD2307@ff.dom.local> <478EE7FD.3010802@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:38525 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbYAQLkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 06:40:33 -0500
Received: by ug-out-1314.google.com with SMTP id z38so330524ugc.16
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 03:40:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478EE7FD.3010802@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2008 at 02:30:37PM +0900, Makito SHIOKAWA wrote:
>> Maybe I'm wrong, but since this read_lock() is given and taken anyway,
>> it seems this looks a bit better to me (why hold this rtnl longer
>> than needed?):
>> 		read_unlock(&bond->lock);
>> 		rtnl_unlock();
>> 		read_lock(&bond->lock);
> Seems better.
>
>> On the other hand, probably 'if (bond->kill_timers)' could be repeated
>> after this read_lock() retaking.
> Sorry, what do you mean? (A case that bond->kill_timers = 1 is done during 
> lock retaking, and work being queued only to do 'if (bond->kill_timers)'? 
> If so, I think that won't differ much.)

Probably the difference is not much, but since this all double locking,
unlocking and something between could take a while, and such a check
looks cheaper than re-queueing... But I don't persist in this.

Jarek P.
