From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB - What's the minimal value for 'rate' parameter?
Date: Thu, 08 Apr 2010 23:33:40 +0200
Message-ID: <4BBE4BB4.1060209@gmail.com>
References: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:48022 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061Ab0DHVdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 17:33:47 -0400
Received: by fxm23 with SMTP id 23so2420206fxm.21
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 14:33:46 -0700 (PDT)
In-Reply-To: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Antonio Almeida wrote, On 04/08/2010 01:07 PM:

> Hi!

Hi!

> I've been using HTB for a while, and we've already sent some e-mails
> each other when resolving HTB accuracy issue.
> When using HTB, I realised that for some configurations the rate limit
> doesn't work.
> I suspect that the problem is the minimum value of rate parameter,
> which I cant figure out what is.
> 
> I simple configuration that turns out to be wrong is as fallows: The
> root (1:1) gets the link bandwidth configuration; the second (1:2) is
> set to 4096Kbit; then I have two branches (1:10 and 1:11) with rate
> 1024Kbit and ceil 4096Kbit; and finally a leaf class in each branch
> (1:111 below 1:11, and 1:101 below 1:10) with rate 8bit and ceil
> 4096Kbit, and the same priority.
> I don't want to have sustained rate, and since I must configure 'rate'
> parameter I decide to set it to 8bits - which is the minimal accepted
> value. My cue goes for 'rate' parameter. If I set 'rate' parameter to
> 1Kbit for instance, the problem disappears and the shaping is done
> perfectly.
> 
> So, I'm looking for help to find out if the problem is actually in
> this parameter configuration or if it's just coincidence and I'll get
> the same problem ahead :(
> What's the minimal value for 'rate' parameter using HTB qdisc?


I think "reasonable" or "minimally useful" (for common use) should be
enough, and 8bits meaning one 1500 byte packet per 25 minutes or
something, doesn't look like this to me.

This changelog:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=a4a710c4a7490587406462bf1d54504b7783d7d7
mentions ~2 minutes as max time for accounting, so 1 max packet
per 2 minutes should give such a minimal rate, I guess, but I'd
still multiply it a few times to call it useful.

Regards,
Jarek P.


