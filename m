From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Tue, 26 Aug 2014 21:54:19 +0100
Message-ID: <20140826205419.GH15316@casper.infradead.org>
References: <20140825225057.GD30140@casper.infradead.org>
 <53FC909D.8090000@cumulusnetworks.com>
 <20140826140630.GA1848@nanopsycho.lan>
 <53FCA0AE.9010304@mojatatu.com>
 <20140826152217.GA1843@nanopsycho.lan>
 <53FCA7C6.5070804@mojatatu.com>
 <20140826154459.GB1843@nanopsycho.lan>
 <20140826155426.GA5275@gospo.rtplab.test>
 <20140826161956.GA15316@casper.infradead.org>
 <CAADnVQLeNTQO9rekWRAb_2MWgiZqEiZ4p6GAsypdkhgg3xQffw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, ben@decadent.org.uk,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	john.r.fastabend@intel.com, Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	"dev@openvswitch.org" <
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52820 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbaHZUy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 16:54:27 -0400
Content-Disposition: inline
In-Reply-To: <CAADnVQLeNTQO9rekWRAb_2MWgiZqEiZ4p6GAsypdkhgg3xQffw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/14 at 01:13pm, Alexei Starovoitov wrote:
> I think it's important distinction. In-kernel OVS is not OF.
> It's a networking function that has hard-coded packet parser,
> N-tuple match and programmable actions.
> There were times when HW vendors were using OF check-box
> to sell more chips, but at the end there is not a single HW
> that is fully OF compliant. OF brand is still around, but
> OF 2.0 is not tcam+action anymore.
> Imo trying to standardize HW offload interface based on OF 1.x
> principles is strange. Does anyone has performance data
> that shows that hard-parser+N-tuple-match offload actually speeds
> up real life applications ?

That really depends on your definition of application. A pure
switch application will obviously benefit. The host case is more
complicated, offloading packet switching doesn't buy you anything
obviously but it does allow to use SR-IOV in a broader context. If
I have to chose between a DPDK host stack bypass and a well
abstracted and flexible SR-IOV bypass I would favour the VF approach.
Especially once things like P4 make its way into hardware and
the flexibility of hardware becomes less of an issue. My interest
is mainly driven from this perspective.

> Why are we designing kernel offload based on 'rocker' emulator?
> Enterprise silicon I've seen doesn't look like it...
> I'm not saying that kernel should not have a driver for rocker.
> It should, but it shouldn't be a golden model for HW offload.

I agree that it shouldn't be the golden model. Is that even
happening? Given the earlier discussions, the only reason rocker
seems to exist is because of lack of public hardware specs. I doubt
that Jiri and Scott are doing this excercise if they wouldn't have
to.
 
> "straw-man proposal for OF 2.0" paper have very
> interesting ideas:
> http://arxiv.org/pdf/1312.1719.pdf
> sooner or later off the shelf NICs will have similar functionality.
> 
> In Linux we already have bridge that is perfect abstraction of
> L2 network functions. OF 1.x has to use 'tcam' to do bridge and
> in-kernel OVS has to fall back to 'mega-flows', but HW has proper
> exact match tables and HW mac learning,
> so OF 1.x principles just don't fit to L2 offloading.

Agreed but I don't think we should restrict this to L2. As you say,
that problem is solved and we have fdb_add() to take care of the
offload.

What we're facing as minimal requirements are L2-L3 forwarding needs
combined with encap and encryption. Does it have to be implemented
with OF1.x flows? No. In fact I would love to use eBPF in the
software path and will support you all the way ;-) P4 hardware will
make that even sweeter. But using a flow model does seem kind of
straight forward to allow for offload with today's available HW n-tuple
filters.
