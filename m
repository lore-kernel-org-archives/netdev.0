From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 01 Jul 2006 09:47:19 -0400
Message-ID: <1151761639.5093.154.camel@jzny2>
References: <1151675843.5270.18.camel@jzny2>
	 <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
	 <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch> <1151701767.5270.289.camel@jzny2>
	 <20060630212047.GP14627@postel.suug.ch> <1151703305.5270.311.camel@jzny2>
	 <20060630232214.GQ14627@postel.suug.ch> <1151720635.5093.15.camel@jzny2>
	 <20060701115112.GT14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:21422 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751271AbWGANrW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jul 2006 09:47:22 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fwfoi-0007PM-Ve
	for netdev@vger.kernel.org; Sat, 01 Jul 2006 09:47:24 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060701115112.GT14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-01-07 at 13:51 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 22:23
> > I am  not certain i understood then: Are we in the mode where the
> > refcount is not needed because chances are small that a device will
> > disappear? It seems to me after all this trouble that it may not be so
> > bad to refcount (I guess i meant refcount the device on input to the ifb
> > and decrement on the output).
> 
> Based on two principles:
> 
>  a) All netdevices a packet is processed through is properly
>     refcounted until the packet is queued for the first time.
>     Given that iif is strictly set to the previous device, a
>     refcnt is certainly taken up to the point where the skb is
>     put into rq. 

yes, but that refcount may be lost by the time it is dequeued and
retransmitted. Am i wrong thinking so?

> There is one exception to this: The fact that
>     you don't set skb->dev = ifb when reinjecting at ingress
>     will not take a refcnt on the ifb. This sounds like a broken
>     architecture to me but it doesn't matter as you want to
>     prohibit ifb -> ifb anyways.

Ok, Thomas: Please stop critiqueing the architecture non-stop. You will
not convince me of anything this way. Lets just focus on this issue and
then you can go back and critique all you want.

>  
>  b) The netdevice used for xmit via dev_queue_xmit() is already
>     protected by the initial xmit attempt.
> 

Is it guaranteed? if yes, the patch is perfect.

> I can't see reason why to hurt performance by introducing more
> atomic operations in your fast path.
> 

well, i would be fine with this - with a caveat that nothing really has
changed in ifb then, no? i.e the value of the patch in that case would
be to convert input_dev to iif, correct? If yes, this is fine by me
since as we have discussed the likelihood of this was small.

> If you have more concerns regarding these patches, feel free to
> fix your own architecture or propose to drop the patches, I think
> I've spend enough time on this.

Again, you are not being helpful by throwing in side remarks like these.
I am being very fair to you when you ask questions on how X works after
all assumptions you make - yet i ask questions which i see as valid and
you start throwing your hands off in the air. And then Patrick says i am
creating endless debates; this is why we go into loops.
Just answer the questions: I am trying to understand or you can choose
to ignore the emails all together.

cheers,
jamal

