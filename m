From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Thu, 9 Aug 2007 08:49:40 +0530
Message-ID: <OFCC5B6697.663C86DD-ON65257332.0011C213-65257332.001247F3@in.ibm.com>
References: <20070808134247.GA9942@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, rdreier@cisco.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808134247.GA9942@gondor.apana.org.au>
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

Herbert Xu <herbert@gondor.apana.org.au> wrote on 08/08/2007 07:12:47 PM:

> On Wed, Aug 08, 2007 at 03:49:00AM -0700, David Miller wrote:
> >
> > Not because I think it obviates your work, but rather because I'm
> > curious, could you test a TSO-in-hardware driver converted to
> > batching and see how TSO alone compares to batching for a pure
> > TCP workload?
>
> You could even lower the bar by disabling TSO and enabling
> software GSO.

I will try with E1000 (though I didn't see improvement when I tested a long
time back). The difference I expect is that TSO would help with large
packets and not necessarily small/medium packets and not definitely in
the case of multiple different skbs (as opposed to single large skb)
getting
queue'd. I think these are two different workloads.

> > I personally don't think it will help for that case at all as
> > TSO likely does better job of coalescing the work _and_ reducing
> > bus traffic as well as work in the TCP stack.
>
> I agree.  I suspect the bulk of the effort is in getting
> these skb's created and processed by the stack so that by
> the time that they're exiting the qdisc there's not much
> to be saved anymore.

However, I am getting a large improvement for IPoIB specifically for this
same case. The reason - batching will help only when queue gets full and
stopped (and to a lesser extent if tx lock was not got, which results
in fewer amount of batching that can be done).

thanks,

- KK
