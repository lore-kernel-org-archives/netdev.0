From: Alex Bennee <kernel-hacker@bennee.com>
Subject: Re: r8169 ethernet hangs after a pm-suspend (and resume)
Date: Thu, 8 Oct 2009 10:27:10 +0100
Message-ID: <b2cdc9f30910080227s17effd97vf13d7e91b153ad17@mail.gmail.com>
References: <b2cdc9f30909090013q1741da26la73da66f1eef975f@mail.gmail.com>
	 <20090909092822.GA18355@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:33494 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756062AbZJHJ2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 05:28:23 -0400
In-Reply-To: <20090909092822.GA18355@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/9/9 Francois Romieu <romieu@fr.zoreil.com>:
> Alex Bennee <kernel-hacker@bennee.com> :
> [...]
>> I've just recently gotten suspend working on my system. Unfortunately
>> after the resume event I loose access to the network.
>> As far as the system is concerned the network is configured properly
>> but every attempt to ping local nodes fails with "Host not reachable".
>
> Can the problem be described as "gigabit link setting does not survive
> suspend/resume" ?

Even further experimentation shows that ethernet functionality can
survive the resume for a few minutes before reseting. Once it gets
into this state even rmmod/modprobing the r8169 driver won't unwedge
the driver.

The symptoms are either the driver detecting an unknown MAC or setting
the physical address to 0xfffffffff which is obviously broken. I
suspect the hardware has gotten itself wedged somehow.

Is there any way to hard reset the chipset (without power cycling the
system)?

-- 
Alex, homepage: http://www.bennee.com/~alex/
http://www.half-llama.co.uk
