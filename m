From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] netlink: use TID instead of PID for automatic id
	assignment
Date: Sun, 31 Oct 2010 21:25:48 -0500
Message-ID: <20101101022548.GA27367@gondor.apana.org.au>
References: <alpine.LNX.2.01.1010312013100.20872@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59661 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab0KACZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 22:25:57 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1010312013100.20872@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 31, 2010 at 08:14:00PM +0100, Jan Engelhardt wrote:
> parent 3985c7ce85039adacdf882904ca096f091d39346 (v2.6.36-9871-g3985c7c)
> commit 183ded547d51508f23f6c18a999f6c165e66c99e
> Author: Jan Engelhardt <jengelh@medozas.de>
> Date:   Sun Oct 31 20:09:36 2010 +0100
> 
> netlink: use TID instead of PID for automatic id assignment
> 
> This makes it easier to identify processes in the output of `ss -af
> netlink` - as I see no reason to force negative space numbers upon
> all but the first socket in a thread group.
> 
> Turns out this reverts v2.6.15-rc4~65.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Nack.  Sockets are typically shared amongst threads so using the
ID of the thread that created it doesn't make much sense when
all the threads in that group use it to send/receive messages.

In any case, this field should not be relied on (please google
the thread "netlink nlmsg_pid supposed to be pid or tid?") as
anybody can claim your PID in the netlink name space.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
