From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Thu, 4 Dec 2014 01:15:15 +0000
Message-ID: <20141204011515.GA15666@casper.infradead.org>
References: <20141202174158.GB9457@casper.infradead.org>
 <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com>
 <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com>
 <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org>
 <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
 <20141203230551.GC8822@casper.infradead.org>
 <CAEP_g=-y_-=r+BHk3VfzxMNwH=B-26DvQrzQ7gkKG8fDG7Mx3g@mail.gmail.com>
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
Received: from casper.infradead.org ([85.118.1.10]:47091 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbaLDBPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 20:15:20 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-y_-=r+BHk3VfzxMNwH=B-26DvQrzQ7gkKG8fDG7Mx3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 at 04:54pm, Jesse Gross wrote:
> I don't think that we actually need a bit. I would expect that ICMP
> generation to be coupled with routing (although this requires being
> able to know what the ultimate MTU is at the time of routing the inner
> packet). If that's the case, you just need to steer between L2 and L3
> processing in the same way that you would today and ICMP would just
> come in the right cases.

I think the MTU awareness is solveable but how do you steer between
L2 and L3? How do you differentiate between an L3 ACL rule in L2 mode
and an actual L3 based forward? dec_ttl? This is what drove me to
the user controlled bit and it became appealing as it allows to
enable/disable PMTU per guest or even per flow/route.
