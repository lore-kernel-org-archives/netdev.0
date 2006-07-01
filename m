From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 1 Jul 2006 13:51:12 +0200
Message-ID: <20060701115112.GT14627@postel.suug.ch>
References: <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch> <1151701767.5270.289.camel@jzny2> <20060630212047.GP14627@postel.suug.ch> <1151703305.5270.311.camel@jzny2> <20060630232214.GQ14627@postel.suug.ch> <1151720635.5093.15.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5584 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964858AbWGALuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2006 07:50:51 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151720635.5093.15.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 22:23
> I am  not certain i understood then: Are we in the mode where the
> refcount is not needed because chances are small that a device will
> disappear? It seems to me after all this trouble that it may not be so
> bad to refcount (I guess i meant refcount the device on input to the ifb
> and decrement on the output).

Based on two principles:

 a) All netdevices a packet is processed through is properly
    refcounted until the packet is queued for the first time.
    Given that iif is strictly set to the previous device, a
    refcnt is certainly taken up to the point where the skb is
    put into rq. There is one exception to this: The fact that
    you don't set skb->dev = ifb when reinjecting at ingress
    will not take a refcnt on the ifb. This sounds like a broken
    architecture to me but it doesn't matter as you want to
    prohibit ifb -> ifb anyways.
 
 b) The netdevice used for xmit via dev_queue_xmit() is already
    protected by the initial xmit attempt.

I can't see reason why to hurt performance by introducing more
atomic operations in your fast path.

If you have more concerns regarding these patches, feel free to
fix your own architecture or propose to drop the patches, I think
I've spend enough time on this.
