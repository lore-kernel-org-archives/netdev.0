From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Wed, 8 Aug 2007 21:55:01 +0100
Message-ID: <20070808215501.4825d74b@oldman>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
	<20070808.034900.85820906.davem@davemloft.net>
	<20070808134247.GA9942@gondor.apana.org.au>
	<1186586075.5155.27.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com,
	Herbert Xu <herbert@gondor.apana.org.au>, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, mcarlson@broadcom.com,
	David Miller <davem@davemloft.net>, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, netdev@vger.kernel.org, kaber@trash.net, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1186586075.5155.27.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Wed, 08 Aug 2007 11:14:35 -0400
jamal <hadi@cyberus.ca> wrote:

> On Wed, 2007-08-08 at 21:42 +0800, Herbert Xu wrote:
> > On Wed, Aug 08, 2007 at 03:49:00AM -0700, David Miller wrote:
> > > 
> > > Not because I think it obviates your work, but rather because I'm
> > > curious, could you test a TSO-in-hardware driver converted to
> > > batching and see how TSO alone compares to batching for a pure
> > > TCP workload?
> > 
> > You could even lower the bar by disabling TSO and enabling
> > software GSO.
> 
> >From my observation for TCP packets slightly above MDU (upto 2K), GSO
> gives worse performance than non-GSO throughput-wise. Actually this has
> nothing to do with batching, rather the behavior is consistent with or
> without batching changes. 
> 
> > > I personally don't think it will help for that case at all as
> > > TSO likely does better job of coalescing the work _and_ reducing
> > > bus traffic as well as work in the TCP stack.
> > 
> > I agree.
> > I suspect the bulk of the effort is in getting
> > these skb's created and processed by the stack so that by
> > the time that they're exiting the qdisc there's not much
> > to be saved anymore.
> 
> pktgen shows a clear win if you test the driver path - which is what you
> should test because thats where the batching changes are. 
> Using TCP or UDP adds other variables[1] that need to be isolated first
> in order to quantify the effect of batching. 
> For throughput and CPU utilization, the benefit will be clear when there
> are a lot more flows. 

Optimizing for pktgen is a mistake for most users. Please show something
useful like router forwarding, TCP (single and multi flow) and/or better
yet application benchmark improvement.
