From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Mon, 24 Sep 2012 18:34:05 +0200
Message-ID: <1348504445.26828.1131.camel@edumazet-glaptop>
References: <20120905043523.GA12988@redhat.com>
	 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
	 <20120914212958.GA25053@redhat.com>
	 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
	 <20120919211059.GA10985@redhat.com>
	 <1348092082.31352.51.camel@edumazet-glaptop>
	 <20120920020223.GA28110@redhat.com>  <20120924153921.GA13845@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40479 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756930Ab2IXQeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 12:34:10 -0400
Received: by bkcjk13 with SMTP id jk13so1039882bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 09:34:09 -0700 (PDT)
In-Reply-To: <20120924153921.GA13845@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 11:39 -0400, Dave Jones wrote:
> On Wed, Sep 19, 2012 at 10:02:23PM -0400, Dave Jones wrote:
>  > On Thu, Sep 20, 2012 at 12:01:22AM +0200, Eric Dumazet wrote:
>  > 
>  >  > I spent some time trying to track this bug, but found nothing so far.
>  >  > 
>  >  > The timer->function are never cleared by TCP stack at tear down, and
>  >  > should be set before fd is installed and can be caught by other threads.
>  >  > 
>  >  > Most likely its a refcounting issue...
>  >  > 
>  >  > Following debugging patch might trigger a bug sooner ?
>  > 
>  > 4 hours so far, nothing.. I'll leave it run overnight, but it doesn't seem to have
>  > made much difference if any.
> 
> One of my over-weekend runs hit this again, but it didn't trigger the WARN that
> your patch added :-/
> 
> 	Dave
> 

OK, I believe I found the reason. I Will post a patch.

open a raw socket AF_INET, TCP_PROTO
+ connect() ->sk_state set to TCP_ESTABLISHED
+ setsockopt( SO_KEEPALIVE, &on)  -> crash


Thanks
