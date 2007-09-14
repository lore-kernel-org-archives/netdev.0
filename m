From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 2/10 REV5] [core] Add skb_blist & support
	for batching
Date: Fri, 14 Sep 2007 16:46:38 +0400
Message-ID: <20070914124637.GC18517@2ka.mipt.ru>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070914090137.17589.60322.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	hadi@cyberus.ca, kaber@trash.net, randy.dunlap@oracle.com,
	jeff@garzik.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, mcarlson@broadcom.com,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	davem@davemloft.net, mchan@broadcom.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070914090137.17589.60322.sendpatchset@K50wks273871wss.in.ibm.com>
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

On Fri, Sep 14, 2007 at 02:31:37PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> @@ -3566,6 +3579,13 @@ int register_netdevice(struct net_device
>  		}
>  	}
>  
> +	if (dev->features & NETIF_F_BATCH_SKBS) {
> +		/* Driver supports batching skb */
> +		dev->skb_blist = kmalloc(sizeof *dev->skb_blist, GFP_KERNEL);
> +		if (dev->skb_blist)
> +			skb_queue_head_init(dev->skb_blist);
> +	}
> +

A nitpick is that you should use sizeof(struct ...) and I think it
requires flag clearing in cae of failed initialization?

>  	/*
>  	 *	nil rebuild_header routine,
>  	 *	that should be never called and used as just bug trap.

-- 
	Evgeniy Polyakov
