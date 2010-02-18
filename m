From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Thu, 18 Feb 2010 16:45:58 -0500
Message-ID: <1266529558.3879.121.camel@bigi>
References: <20100217191718.GA5256@x200> <1266442972.17794.51.camel@bigi>
	 <1266448038.17794.135.camel@bigi> <1266449529.17794.157.camel@bigi>
	 <20100218185510.GA18829@x200>  <1266526416.3879.109.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:60819 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186Ab0BRVqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 16:46:01 -0500
Received: by qyk38 with SMTP id 38so3249667qyk.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:46:00 -0800 (PST)
In-Reply-To: <1266526416.3879.109.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-18 at 15:53 -0500, jamal wrote:

> Agree - that is a better alternative.
> I was hoping returning an error code of 0 will do that.
> But that triggers the EAGAIN you saw. It doesnt trigger
> an EAGAIN for the netlink side (and it is a nop there).
> Let me look at it. Clearly the EAGAIN is causing the 
> latency.

Ok, looking closely at the strace i think ive figured out
what pfkey is doing. It basically sets non-blocking receive
and expects to see the flush event whether real or bogus
(EAGAIN is because it tries to recvmsg and fails the first
time because we dont send the event when table is empty).

The two options are: 1) Restore old behavior just for pfkey
where bogus event is sent always or 2) return -ESRCH as I
have done in the last patch.
I think #2 is more accurate. But if that is going to break
existing scripts then #1 is the way to go.

Thoughts?

cheers,
jamal



