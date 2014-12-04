From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Thu, 4 Dec 2014 09:26:50 +0000
Message-ID: <20141204092650.GA13660@casper.infradead.org>
References: <20141203090339.GA9299@redhat.com>
 <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com>
 <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org>
 <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
 <20141203230551.GC8822@casper.infradead.org>
 <CAEP_g=-y_-=r+BHk3VfzxMNwH=B-26DvQrzQ7gkKG8fDG7Mx3g@mail.gmail.com>
 <20141204011515.GA15666@casper.infradead.org>
 <CAEP_g=8U_w+dxUHsTH2JQ9dGNHaJp-ai8pdmrfeYBin9NZ46jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49577 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbaLDJ0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 04:26:55 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=8U_w+dxUHsTH2JQ9dGNHaJp-ai8pdmrfeYBin9NZ46jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 at 05:51pm, Jesse Gross wrote:
> I think it depends on where you put the PMTU check. If routing is
> happening in OVS where it is decomposed in several discrete actions
> like set MAC and decrement TTL then perhaps there is another explicit
> action to check the MTU. If it is happening in the context of the IP
> stack, then ICMP generation occurs automatically and if you get that
> if you write a flow to send a packet there. In each case, it seems
> like a flow would be steering you by way of an action to do routing so
> you would have fine grained control. I don't see this as conflicting
> with L3 ACLs in an L2 context in the same way that you don't have to
> automatically decrement the TTL.

OK, I was under the impression that you would detect L3 behaviour
desire in OVS without an explicit action. Hence the worry on wrong
classification for L3 ACLs.

Whether we mark the packet and defer the MTU check or we check right
in the action is an implementation detail in the end. I think we
agree on concept level that we need an API to control behaviour.
