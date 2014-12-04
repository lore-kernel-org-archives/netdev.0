From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 17:51:43 -0800
Message-ID: <CAEP_g=8U_w+dxUHsTH2JQ9dGNHaJp-ai8pdmrfeYBin9NZ46jQ@mail.gmail.com>
References: <20141202174158.GB9457@casper.infradead.org> <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com> <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com> <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org> <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
 <20141203230551.GC8822@casper.infradead.org> <CAEP_g=-y_-=r+BHk3VfzxMNwH=B-26DvQrzQ7gkKG8fDG7Mx3g@mail.gmail.com>
 <20141204011515.GA15666@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:48992 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751639AbaLDBwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 20:52:04 -0500
Received: by mail-qg0-f46.google.com with SMTP id z107so11781904qgd.19
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 17:52:03 -0800 (PST)
In-Reply-To: <20141204011515.GA15666@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 3, 2014 at 5:15 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/03/14 at 04:54pm, Jesse Gross wrote:
>> I don't think that we actually need a bit. I would expect that ICMP
>> generation to be coupled with routing (although this requires being
>> able to know what the ultimate MTU is at the time of routing the inner
>> packet). If that's the case, you just need to steer between L2 and L3
>> processing in the same way that you would today and ICMP would just
>> come in the right cases.
>
> I think the MTU awareness is solveable but how do you steer between
> L2 and L3? How do you differentiate between an L3 ACL rule in L2 mode
> and an actual L3 based forward? dec_ttl? This is what drove me to
> the user controlled bit and it became appealing as it allows to
> enable/disable PMTU per guest or even per flow/route.

I think it depends on where you put the PMTU check. If routing is
happening in OVS where it is decomposed in several discrete actions
like set MAC and decrement TTL then perhaps there is another explicit
action to check the MTU. If it is happening in the context of the IP
stack, then ICMP generation occurs automatically and if you get that
if you write a flow to send a packet there. In each case, it seems
like a flow would be steering you by way of an action to do routing so
you would have fine grained control. I don't see this as conflicting
with L3 ACLs in an L2 context in the same way that you don't have to
automatically decrement the TTL.
