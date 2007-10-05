From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH V6 1/9] IB/ipoib: Bound the net device to the ipoib_neigh
 structue
Date: Fri, 05 Oct 2007 13:57:17 -0400
Message-ID: <47067AFD.40802@pobox.com>
References: <16822.1191538040@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Moni Shoua <monisonlists@gmail.com>,
	Roland Dreier <rdreier@cisco.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47906 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756898AbXJER50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 13:57:26 -0400
In-Reply-To: <16822.1191538040@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> IPoIB uses a two layer neighboring scheme, such that for each struct neighbour
> whose device is an ipoib one, there is a struct ipoib_neigh buddy which is
> created on demand at the tx flow by an ipoib_neigh_alloc(skb->dst->neighbour)
> call.
> 
> When using the bonding driver, neighbours are created by the net stack on behalf
> of the bonding (master) device. On the tx flow the bonding code gets an skb such
> that skb->dev points to the master device, it changes this skb to point on the
> slave device and calls the slave hard_start_xmit function.
> 
> Under this scheme, ipoib_neigh_destructor assumption that for each struct
> neighbour it gets, n->dev is an ipoib device and hence netdev_priv(n->dev)
> can be casted to struct ipoib_dev_priv is buggy.
> 
> To fix it, this patch adds a dev field to struct ipoib_neigh which is used
> instead of the struct neighbour dev one, when n->dev->flags has the
> IFF_MASTER bit set.
> 
> Signed-off-by: Moni Shoua <monis at voltaire.com>
> Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
> Acked-by: Roland Dreier <rdreier@cisco.com>

ACK, but patches do not apply to jgarzik/netdev-2.6.git#upstream nor 
davem/net-2.6.24.git, so I was forced to drop the patch series :(

