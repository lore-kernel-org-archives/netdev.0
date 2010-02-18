From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Thu, 18 Feb 2010 17:52:41 -0500
Message-ID: <1266533561.3879.132.camel@bigi>
References: <20100218185510.GA18829@x200> <1266526416.3879.109.camel@bigi>
	 <1266529558.3879.121.camel@bigi>
	 <20100218.142735.230862605.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:37115 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab0BRWwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 17:52:46 -0500
Received: by qyk38 with SMTP id 38so3284757qyk.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 14:52:45 -0800 (PST)
In-Reply-To: <20100218.142735.230862605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-18 at 14:27 -0800, David Miller wrote:

> Let's see how #2 works out, if we get any more breakage
> cases reported then we'll have to revert again and go with
> #1.

Actually, i think i found the root cause. The sequence should be:

1) pfkey->kernel: flush
kernel flushes SA/SPD
2)kernel->pfkey: respond to flush message
3)kernel->all user space listeners: i just flushed the SA/SPD

#2 is always needed.
#3 is wrong if SA/SPD is empty.
kernel unfortunately sends a single broadcast which combines
#2 and #3. So the proper fix is to break #2 and #3 into
separate messages. And follow the rules above.

I dont have time to fix it right now - but i will send a patch
tommorow.

cheers,
jamal

