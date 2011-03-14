From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 19:57:12 +0100
Message-ID: <1300129032.3423.170.camel@edumazet-laptop>
References: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62025 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab1CNTGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 15:06:40 -0400
Received: by fxm17 with SMTP id 17so3235240fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 12:06:39 -0700 (PDT)
In-Reply-To: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 14:27 +0000, Ian Campbell a =C3=A9crit :

=2E..

> +struct xenvif {
> +	/* Unique identifier for this interface. */
> +	domid_t          domid;
> +	unsigned int     handle;
> +
> +	/* Reference to netback processing backend. */
> +	struct xen_netbk *netbk;
> +
> +	u8               fe_dev_addr[6];
> +
> +	/* Physical parameters of the comms window. */
> +	grant_handle_t   tx_shmem_handle;
> +	grant_ref_t      tx_shmem_ref;
> +	grant_handle_t   rx_shmem_handle;
> +	grant_ref_t      rx_shmem_ref;
> +	unsigned int     irq;
> +
> +	/* List of frontends to notify after a batch of frames sent. */
> +	struct list_head notify_list;
> +
> +	/* The shared rings and indexes. */
> +	struct xen_netif_tx_back_ring tx;
> +	struct xen_netif_rx_back_ring rx;
> +	struct vm_struct *tx_comms_area;
> +	struct vm_struct *rx_comms_area;
> +
> +	/* Flags that must not be set in dev->features */
> +	u32 features_disabled;
> +
> +	/* Frontend feature information. */
> +	u8 can_sg:1;
> +	u8 gso:1;
> +	u8 gso_prefix:1;
> +	u8 csum:1;
> +
> +	/* Internal feature information. */
> +	u8 can_queue:1;	    /* can queue packets for receiver? */
> +
> +	/*
> +	 * Allow xenvif_start_xmit() to peek ahead in the rx request
> +	 * ring.  This is a prediction of what rx_req_cons will be
> +	 * once all queued skbs are put on the ring.
> +	 */
> +	RING_IDX rx_req_cons_peek;
> +
> +	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
> +	unsigned long   credit_bytes;
> +	unsigned long   credit_usec;
> +	unsigned long   remaining_credit;
> +	struct timer_list credit_timeout;
> +
> +	/* Statistics */
> +	unsigned long rx_gso_checksum_fixup;

this is an "unsigned long" field

> +
> +	/* Miscellaneous private stuff. */
> +	struct list_head schedule_list;
> +	atomic_t         refcnt;
> +	struct net_device *dev;
> +
> +	wait_queue_head_t waiting_to_free;
> +};
> +


> +static void xenvif_get_ethtool_stats(struct net_device *dev,
> +				     struct ethtool_stats *stats, u64 * data)
> +{
> +	void *vif =3D netdev_priv(dev);
> +	int i;
> +
> +	for (i =3D 0; i < ARRAY_SIZE(xenvif_stats); i++)
> +		data[i] =3D *(int *)(vif + xenvif_stats[i].offset);

so use : data[i] =3D *(unsigned long *)(vif + xenvif_stats[i].offset);

> +}
> +



