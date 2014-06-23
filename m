From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v2] xen-netback: bookkeep number of
 active queues in our own module
Date: Mon, 23 Jun 2014 09:40:32 +0100
Message-ID: <20140623084032.GU20819@zion.uk.xensource.com>
References: <1403443901-5404-1-git-send-email-wei.liu2@citrix.com>
	<20140622.172105.1949118384610767695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, boris.ostrovsky@oracle.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <20140622.172105.1949118384610767695.davem@davemloft.net>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 22, 2014 at 05:21:05PM -0700, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Sun, 22 Jun 2014 14:31:41 +0100
> 
> >  
> > +	/* Initialisation completed, tell core driver the number of
> > +	 * active queues.
> > +	 */
> > +	rtnl_lock();
> > +	netif_set_real_num_tx_queues(be->vif->dev, requested_num_queues);
> > +	netif_set_real_num_rx_queues(be->vif->dev, requested_num_queues);
> > +	rtnl_unlock();
> > +
> >  	xenvif_carrier_on(be->vif);
> 
> This function _NEVER_ set the number of RX queues beforehand,
> therefore why are you adding an RX queue adjustment now?
> 

As I went through the core driver code I found this to be a missing call
in previous code.

"In current Xen multiqueue design, the number of TX queues and RX queues
are in fact the same. So we need to set the numbers of TX and RX queues
to the same value."

Does the above paragraph answers your question? If so, I will add it to
commit message and resend this patch.

> Regardless of the reason, you must explain such a change, in
> detail, in your commit message.
> 
> Your previous patch didn't do this, and I really am suspect as to
> whether you functionally tested and verified this aspect of your
> change at a ll.
> 

I've done some testing.

> Please don't "quietly" make undescribed changes like this. It's very
> tiring to think that a patch has been adjusted to my liking and then
> during review I find a grenade like this :-/
> 

Sorry, that wasn't my intent.

Wei.

> Thanks.
