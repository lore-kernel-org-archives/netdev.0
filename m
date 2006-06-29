From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 01:39:33 +0200
Message-ID: <20060629233933.GB14627@postel.suug.ch>
References: <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net> <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2> <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:25763 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751315AbWF2XjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 19:39:13 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151623394.8922.27.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-29 19:23
> > What's currently
> > done in ifb:
> > 
> > 	skb->dev = skb->input_dev;
> > 	skb->input_dev = dev;
> > 
> > Confusing, isn't it? 
> 
> not at all. Let me explain the design intent further below.

Then let me show you what your code does:

 [mirred attached to filter on eth0 redirecting to ifb0]

tcf_mirred():    skb2->input_dev = skb->dev; (skb2->input_dev=eth0)
ifb_xmit():      skb->dev = skb->input_dev; (skb->dev=eth0)
                 skb->input_dev = dev; (skb->input_dev=ifb0)

So when reentering the stack the skb looks like it would be
on eth0 coming from ifb0. Is that what you wanted? Shouldn't
it be skb->dev=ifb0 skb->input_dev=eth0? That's what my patch
would change it to.

> I know your intent is noble in trying to save the 32 bits on 64 bit
> machines (at least thats where your patch seems to have started) but the
> cost:benefit ratio as i have pointed out is unreasonable. 

Did I ever claim this? You made this up right now. As of now
it doesn't save a single bit.

