From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [patch] netlink: use TID instead of PID for automatic id
 assignment
Date: Mon, 1 Nov 2010 09:27:39 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011010925400.16087@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1010312013100.20872@obet.zrqbmnf.qr> <20101101022548.GA27367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:60864 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263Ab0KAI1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 04:27:40 -0400
In-Reply-To: <20101101022548.GA27367@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2010-11-01 03:25, Herbert Xu wrote:
>> 
>> netlink: use TID instead of PID for automatic id assignment
>> 
>> This makes it easier to identify processes in the output of `ss -af
>> netlink` - as I see no reason to force negative space numbers upon
>> all but the first socket in a thread group.
>> 
>> Turns out this reverts v2.6.15-rc4~65.
>> 
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>
>Nack.  Sockets are typically shared amongst threads so using the
>ID of the thread that created it doesn't make much sense when
>all the threads in that group use it to send/receive messages.

That would be fine, because they are in the same process.

>In any case, this field should not be relied on (please google
>the thread "netlink nlmsg_pid supposed to be pid or tid?") as
>anybody can claim your PID in the netlink name space.

I am aware of that. But then it raises the question why we are
giving the first socket a non-negative value in the first place.
