From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC 1/3] tc: fix return values of ingress qdisc
Date: Thu, 23 Apr 2015 09:46:12 +0100
Message-ID: <20150423084612.GH21799@casper.infradead.org>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
 <1429644476-8914-2-git-send-email-ast@plumgrid.com>
 <CAHA+R7NwAdc81bFSoqvXsTpzod0vzT-PV38_Q0N0WTUVGFUY-g@mail.gmail.com>
 <55381AD3.30209@plumgrid.com>
 <CAHA+R7ODYz4Awh-HuxARktS2vdUa_pEbN_8DZY1Qk4mH7vd=9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34463 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756836AbbDWIqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 04:46:18 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7ODYz4Awh-HuxARktS2vdUa_pEbN_8DZY1Qk4mH7vd=9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/15 at 04:29pm, Cong Wang wrote:
> On Wed, Apr 22, 2015 at 3:04 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> > On 4/21/15 9:59 PM, Cong Wang wrote:
> >>
> >> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com>
> >> wrote:
> >>>
> >>> ingress qdisc should return NET_XMIT_* values just like all other qdiscs.
> >>>
> >>
> >> XMIT already means egress...
> >
> >
> > may be then it should be renamed as well.
> > from include/linux/netdevice.h:
> > /* qdisc ->enqueue() return codes. */
> > #define NET_XMIT_SUCCESS        0x00
> > ...
> >
> > the point is that qdisc->enqeue() must return NET_XMIT_* values.
> > ingress qdisc is violating this and therefore should be fixed.
> 
> XMIT is non-sense for ingress, you really need to pick another
> name for it if TC_ACT_OK isn't okay for you (it is okay for me).

You transmit into a qdisc. If that terminology doesn't suit
you then rename it to NET_QUEUE_* but moving away from returning
TC_ACT_* is definitely the right thing to do here.
> 
