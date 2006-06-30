From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 1 Jul 2006 01:22:14 +0200
Message-ID: <20060630232214.GQ14627@postel.suug.ch>
References: <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch> <1151701767.5270.289.camel@jzny2> <20060630212047.GP14627@postel.suug.ch> <1151703305.5270.311.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:24769 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932289AbWF3XVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 19:21:53 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151703305.5270.311.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is boring, I reversed everything to not change any semantics and
you still complain.

* jamal <hadi@cyberus.ca> 2006-06-30 17:35
> On Fri, 2006-30-06 at 23:20 +0200, Thomas Graf wrote:
> > * jamal <hadi@cyberus.ca> 2006-06-30 17:09
> > > the ref inside the else below after changing input_dev 
> > 
> > A non-existant iif is already equivalent to !iif since it jumps
> > into the same branch. 
> 
> I thought 0 was a valid iif as Ben G was pointing - if it is not, you
> are right. 

No, 1 ist the first valid ifindex, see dev_new_index().

> > Grabing a reference is completely pointless,
> > the netdevice represented by skb->iif is at this point until the
> > packet gets queued covered by a reference taken in netif_rx().
> 
> You have to consider that this could happen at both ingress and egress.

Just think for a second, do you expect the device the packet will
be leaving at to disappear?
