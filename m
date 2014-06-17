From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v6 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Tue, 17 Jun 2014 12:21:08 -0700
Message-ID: <CAKh23F=2undAW=nWibOreAM8DJiQKpLx=OboCX=fNZE+OU=AbA@mail.gmail.com>
References: <1402964326-11147-1-git-send-email-isubramanian@apm.com>
	<1402964326-11147-5-git-send-email-isubramanian@apm.com>
	<20140616.214247.1154200670003936158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140616.214247.1154200670003936158.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 16, 2014 at 9:42 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Date: Mon, 16 Jun 2014 17:18:46 -0700
>
>> +static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
>> +                                      struct net_device *ndev)
>> +{
>> +     struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>> +     struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
>> +     struct xgene_enet_desc_ring *cp_ring = tx_ring->cp_ring;
>> +     u32 tx_level, cq_level;
>> +
>> +     tx_level = xgene_enet_ring_len(tx_ring);
>> +     cq_level = xgene_enet_ring_len(cp_ring);
>> +     if (unlikely(tx_level > pdata->tx_qcnt_hi ||
>> +                  cq_level > pdata->cp_qcnt_hi)) {
>> +             netif_stop_queue(ndev);
>> +             return NETDEV_TX_BUSY;
>> +     }
>> +
>> +     if (xgene_enet_setup_tx_desc(tx_ring, skb))
>> +             return NETDEV_TX_OK;
>
> If you return NETDEV_TX_OK, it is your responsibility to deal with the
> SKB, because you own it.
>
> In particular, you have to free the packet.

skb freeing happens in xgene_enet_tx_completion().
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
