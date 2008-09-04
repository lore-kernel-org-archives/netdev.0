From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: SunHME: trying to enable netconsole/netpolling
Date: Thu, 4 Sep 2008 08:20:17 +0000
Message-ID: <20080904082017.GB4691@ff.dom.local>
References: <20080903.135904.18076182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.beregalov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:49135 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbYIDIUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 04:20:25 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2737948wri.5
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 01:20:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080903.135904.18076182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-09-2008 22:59, David Miller wrote:
> From: "Alexander Beregalov" <a.beregalov@gmail.com>
> Date: Wed, 3 Sep 2008 20:26:54 +0400
> 
>> Hi David
>>
>> Can you please advice
>> I am a newbie here.
>> I am trying to enable netconsole output with sunhme card,
>> I found that poll_controller is not defined and defined it
>> as it is defined in other drivers (just to watch if it will work, I
>> dont understand this code yet)
>> My patch is in attach.
>> My card is connected to PCI bus.
> 
> It isn't going to work until sunhme is converted to NAPI, and that
> may never happen.
> 
> So unless someone knowledgable wants to do the work, which certianly
> is not me, sunhme for now will not support netconsole.

Alas I'm not someone like this, and probably there are some deeper
problems here, but I wonder if could try to look at 3c509.c (non-NAPI
too), especially wrt.  locking, so spin_lock_irqsave /irqrestore() in
happy_meal_start_xmit() and disable_irq()/enable_irq() in this
poll_controller wrapper? 

Jarek P.
