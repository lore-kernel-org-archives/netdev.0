From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 22:23:55 -0400
Message-ID: <1151720635.5093.15.camel@jzny2>
References: <1151629890.8922.121.camel@jzny2>
	 <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2>
	 <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
	 <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch> <1151701767.5270.289.camel@jzny2>
	 <20060630212047.GP14627@postel.suug.ch> <1151703305.5270.311.camel@jzny2>
	 <20060630232214.GQ14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:15790 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750889AbWGACX7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 22:23:59 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwV9R-0002Ln-L5
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 22:24:05 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630232214.GQ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-01-07 at 01:22 +0200, Thomas Graf wrote:
> This is boring, I reversed everything to not change any semantics and
> you still complain.
> 

You reversed a bug that you had introduced. Do you want me to review
this patch or not now? Be a little reasonable please.

> * jamal <hadi@cyberus.ca> 2006-06-30 17:35

> > > Grabing a reference is completely pointless,
> > > the netdevice represented by skb->iif is at this point until the
> > > packet gets queued covered by a reference taken in netif_rx().
> > 
> > You have to consider that this could happen at both ingress and egress.
> 
> Just think for a second, do you expect the device the packet will
> be leaving at to disappear?

I am  not certain i understood then: Are we in the mode where the
refcount is not needed because chances are small that a device will
disappear? It seems to me after all this trouble that it may not be so
bad to refcount (I guess i meant refcount the device on input to the ifb
and decrement on the output).

As a note - and i am sure you know this: 
The packet comes to the ifb and gets queued. It gets dequeued at a later
time and is sent off either to the ingress or egress. At any point
during the enq/deq the other device being referenced could 
disappear. This is a lesser sin on ingress than it is on egress.

cheers,
jamal

