From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 07 Apr 2009 16:56:40 -0400
Message-ID: <1239137800.21227.10.camel@dogo.mojatatu.com>
References: <1238701718.5669.26.camel@bender>
	 <20090407072647.GA11480@gondor.apana.org.au>
	 <1239108520.32737.28.camel@dogo.mojatatu.com>
	 <20090407130447.GA14329@gondor.apana.org.au>
	 <1239112067.32737.51.camel@dogo.mojatatu.com>
	 <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:39529 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757757AbZDGU7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 16:59:37 -0400
Received: by fg-out-1718.google.com with SMTP id e12so998387fga.17
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2009 13:59:35 -0700 (PDT)
In-Reply-To: <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-07 at 16:38 +0200, Johann Baudy wrote:
> Hi All, 
> Many thanks for your replies!
> 
> Indeed, I've tried to find a solution to store data in skb (valid
> until destructor).

Makes sense for what you are trying to do (or someone else a long
while back who wanted to notify user space of a sent skb).
Any skb metadata can mutate along its path. Actually even
if you used a field off the skb->data it too could be changed 
somewhere along the path before destructor is invoked.
There maybe a "hard way" to achieve your goal: use the address
of the skb to derive your index; i am not 100% sure if your destructor
will always be called (check skb_expand() for example).

cheers,
jamal

