From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: System blocks (hangs) on ifconfig up
Date: Sun, 12 Dec 2010 23:03:03 +0000
Message-ID: <1292194983.3136.294.camel@localhost>
References: <4D04E38A.1040605@trego.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shmulik Hen <shmulik.hen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37917 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab0LLXDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 18:03:07 -0500
In-Reply-To: <4D04E38A.1040605@trego.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-12 at 17:00 +0200, Shmulik Hen wrote:
> Hello,
> 
> My system is Ubuntu 10.04, running kernel 2.6.32-26-generic.
> 
> Whenever I try to bring up a specific ethernet interface for the second 
> time, my
> system becomes unresponsive for 60 seconds - i.e. no mouse, no keyboard, no
> screen refresh. etc.
> 
> Looking at the driver's code, I could see that it's dev->open() method calls
> wait_event_interruptible_timeout() with a timeout of 60 seconds - exactly
> the delay I'm seeing.

That seems like a stupid thing for it to do.

> I have narrowed the code to a bare minimum (see below - loosely based on
> dummy.c), which only calls mdelay(10000) in it's dev->open() method, and
> still, my system blocks for exactly 10 seconds when I run the following
> sequence:
> 
>  > sudo ifconfig shmulik0 up
>  > sudo ifconfig shmulik0 down
>  > sudo ifconfig shmulik0 up
> 
> At this point - the system is stuck for 10 seconds.

Bringing an interface up or down is a synchronous operation and is
serialised with most other network configuration operations.  So this is
the expected behaviour.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

