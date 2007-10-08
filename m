From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 8 Oct 2007 10:33:27 +0530
Message-ID: <OF9A1CB7CB.5E22F8B7-ON6525736E.001B7EF8-6525736E.001BC875@in.ibm.com>
References: <1191244900.4378.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191244900.4378.3.camel@localhost>
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

> jamal wrote:
>
> > > +   while ((skb = __skb_dequeue(skbs)) != NULL)
> > > +      q->ops->requeue(skb, q);
> >
> >
> > ->requeue queues at the head, so this looks like it would reverse
> > the order of the skbs.
>
> Excellent catch!  thanks; i will fix.
>
> As a side note: Any batching driver should _never_ have to requeue; if
> it does it is buggy. And the non-batching ones if they ever requeue will
> be a single packet, so not much reordering.

On the contrary, batching LLTX drivers (if that is not ruled out) will very
often requeue resulting in heavy reordering. Fix looks good though.

- KK
