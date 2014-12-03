From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 11:38:07 -0800
Message-ID: <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
References: <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org> <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com> <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, "Du, Fan" <fan.du@intel.com>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog020.obsmtp.com ([74.125.150.80]:51462 "HELO
	na6sys009bog020.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750862AbaLCTid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 14:38:33 -0500
Received: by mail-qc0-f178.google.com with SMTP id b13so12715073qcw.23
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 11:38:27 -0800 (PST)
In-Reply-To: <20141203183859.GB16447@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 3, 2014 at 10:38 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Wed, Dec 03, 2014 at 10:07:42AM -0800, Jesse Gross wrote:.
>> ICMP can't be the complete solution in any case because it only works
>> for IP traffic.
>
> Let's be specific please.  What protocols do you most care about? IPX?
>
>> I think there are only two full solutions: find a way
>> to adjust the guest MTU to the minimum MTU that its traffic could hit
>> in an L2 domain or fragmentation. ICMP could be a possible
>> optimization in the fragmentation case.
>
> Both approaches seem strange. You are sending 1 packet an hour to
> some destination behind 100 tunnels. Why would you want to
> cut down your MTU for all packets? On the other hand,
> doubling the amount of packets because your MTU is off
> by a couple of bytes will hurt performance significantly.
>
> Still, if you want to cut down the MTU within guest,
> that's only an ifconfig away.
> Most people would not want to bother, I think it's a good
> idea to make PMTU work properly for them.

I care about correctness first, which means that an Ethernet link
being exposed to the guest should behave like Ethernet. So, yes, IPX
should work if somebody chooses to do that.

Your comments are about performance optimization. That's fine but
without a correct base to start from it seems like putting the cart
before the horse and is hard to reason about.
