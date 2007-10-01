From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 01 Oct 2007 09:21:40 -0400
Message-ID: <1191244900.4378.3.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>
	<1190570409.4256.62.camel@localhost>
	<1191178346.6165.29.camel@localhost> <4700CF14.2010809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4700CF14.2010809@trash.net>
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

On Mon, 2007-01-10 at 12:42 +0200, Patrick McHardy wrote:
> jamal wrote:

> > +	while ((skb = __skb_dequeue(skbs)) != NULL)
> > +		q->ops->requeue(skb, q);
> 
> 
> ->requeue queues at the head, so this looks like it would reverse
> the order of the skbs.

Excellent catch!  thanks; i will fix.

As a side note: Any batching driver should _never_ have to requeue; if
it does it is buggy. And the non-batching ones if they ever requeue will
be a single packet, so not much reordering.

Thanks again Patrick.

cheers,
jamal
