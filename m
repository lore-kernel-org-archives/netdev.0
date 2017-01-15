From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] secure_seq: initialize secret at boot instead of at runtime
Date: Sun, 15 Jan 2017 16:37:31 +0100
Message-ID: <587B973B.8040008@iogearbox.net>
References: <20170115140136.23135-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43126 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbdAOPhf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 10:37:35 -0500
In-Reply-To: <20170115140136.23135-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2017 03:01 PM, Jason A. Donenfeld wrote:
> While the static key stuff is fast, it's not as fast as simply not
> having any code to run. So, this patch generates the secret at
> boot, rather than at runtime.
>
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> ---
> I can imagine this patch not being desirable because:
>
>    a) It was done this way in the first place for a reason. (Which?)

See git log:

commit aebda156a570782a86fc4426842152237a19427d
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Apr 29 05:58:52 2013 +0000

     net: defer net_secret[] initialization

     Instead of feeding net_secret[] at boot time, defer the init
     at the point first socket is created.

     This permits some platforms to use better entropy sources than
     the ones available at boot time.

     Signed-off-by: Eric Dumazet <edumazet@google.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>
