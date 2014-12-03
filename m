From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 23:05:51 +0000
Message-ID: <20141203230551.GC8822@casper.infradead.org>
References: <20141202170927.GA9457@casper.infradead.org>
 <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org>
 <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com>
 <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com>
 <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org>
 <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
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
Received: from casper.infradead.org ([85.118.1.10]:46461 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbaLCXFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 18:05:55 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 at 02:51pm, Jesse Gross wrote:
> My proposal would be something like this:
>  * For L2, reduce the VM MTU to the lowest common denominator on the segment.
>  * For L3, use path MTU discovery or fragment inner packet (i.e.
> normal routing behavior).
>  * As a last resort (such as if using an old version of virtio in the
> guest), fragment the tunnel packet.

That's what I had in mind as well although using a differentiator bit
which indicates to the output path whether the packet is to be
considered switched or routed and thus send ICMPs. The bit would be set
per flow, thus allowing arbitary granularity of behaviour.

I haven't fully thought this through yet though.
