From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 01 Oct 2007 12:42:28 +0200
Message-ID: <4700CF14.2010809@trash.net>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>	
	<20070916.161748.48388692.davem@davemloft.net>	
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>	
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>	
	<1190570409.4256.62.camel@localhost>
	<1191178346.6165.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191178346.6165.29.camel@localhost>
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

jamal wrote:
> +static inline int
> +dev_requeue_skbs(struct sk_buff_head *skbs, struct net_device *dev,
> +	       struct Qdisc *q)
> +{
> +
> +	struct sk_buff *skb;
> +
> +	while ((skb = __skb_dequeue(skbs)) != NULL)
> +		q->ops->requeue(skb, q);


->requeue queues at the head, so this looks like it would reverse
the order of the skbs.
