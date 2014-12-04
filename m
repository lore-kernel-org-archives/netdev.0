From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Thu, 4 Dec 2014 15:19:47 -0800
Message-ID: <CAEP_g=9BvhQfGKveCXgTa92vuWMp3-V8MHP+eiABvyzQFF08nA@mail.gmail.com>
References: <20141203090339.GA9299@redhat.com> <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com> <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org> <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
 <20141203230551.GC8822@casper.infradead.org> <CAEP_g=-y_-=r+BHk3VfzxMNwH=B-26DvQrzQ7gkKG8fDG7Mx3g@mail.gmail.com>
 <20141204011515.GA15666@casper.infradead.org> <CAEP_g=8U_w+dxUHsTH2JQ9dGNHaJp-ai8pdmrfeYBin9NZ46jQ@mail.gmail.com>
 <20141204092650.GA13660@casper.infradead.org>
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
Received: from na6sys009bog037.obsmtp.com ([74.125.150.111]:37631 "HELO
	na6sys009bog037.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753069AbaLDXUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 18:20:09 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so15062625qcw.6
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 15:20:08 -0800 (PST)
In-Reply-To: <20141204092650.GA13660@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2014 at 1:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/03/14 at 05:51pm, Jesse Gross wrote:
>> I think it depends on where you put the PMTU check. If routing is
>> happening in OVS where it is decomposed in several discrete actions
>> like set MAC and decrement TTL then perhaps there is another explicit
>> action to check the MTU. If it is happening in the context of the IP
>> stack, then ICMP generation occurs automatically and if you get that
>> if you write a flow to send a packet there. In each case, it seems
>> like a flow would be steering you by way of an action to do routing so
>> you would have fine grained control. I don't see this as conflicting
>> with L3 ACLs in an L2 context in the same way that you don't have to
>> automatically decrement the TTL.
>
> OK, I was under the impression that you would detect L3 behaviour
> desire in OVS without an explicit action. Hence the worry on wrong
> classification for L3 ACLs.
>
> Whether we mark the packet and defer the MTU check or we check right
> in the action is an implementation detail in the end. I think we
> agree on concept level that we need an API to control behaviour.

Yes, I agree.
