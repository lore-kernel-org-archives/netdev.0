From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v6 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Wed, 18 Jun 2014 16:46:11 -0700
Message-ID: <CAKh23FmnZqZkDaGYPfnKRrvCYQ4_6W_RRKbqEbc4nbD6jqQaLA@mail.gmail.com>
References: <1402964326-11147-5-git-send-email-isubramanian@apm.com>
	<20140616.214247.1154200670003936158.davem@davemloft.net>
	<CAKh23F=2undAW=nWibOreAM8DJiQKpLx=OboCX=fNZE+OU=AbA@mail.gmail.com>
	<20140617.132024.1213369771856463527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"jcm@redhat.com" <jcm@redhat.com>, patches <patches@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og109.obsmtp.com ([64.18.0.188]:33489 "HELO
	exprod5og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756186AbaFRXqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 19:46:13 -0400
Received: by mail-lb0-f176.google.com with SMTP id w7so955066lbi.21
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 16:46:11 -0700 (PDT)
In-Reply-To: <20140617.132024.1213369771856463527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 1:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Iyappan Subramanian <isubramanian@apm.com>
> Date: Tue, 17 Jun 2014 12:21:08 -0700
>
>> On Mon, Jun 16, 2014 at 9:42 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Iyappan Subramanian <isubramanian@apm.com>
>>> Date: Mon, 16 Jun 2014 17:18:46 -0700
>>>
>>>> +static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
>>>> +                                      struct net_device *ndev)
>>>> +{
>>>> +     struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>>>> +     struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
>>>> +     struct xgene_enet_desc_ring *cp_ring = tx_ring->cp_ring;
>>>> +     u32 tx_level, cq_level;
>>>> +
>>>> +     tx_level = xgene_enet_ring_len(tx_ring);
>>>> +     cq_level = xgene_enet_ring_len(cp_ring);
>>>> +     if (unlikely(tx_level > pdata->tx_qcnt_hi ||
>>>> +                  cq_level > pdata->cp_qcnt_hi)) {
>>>> +             netif_stop_queue(ndev);
>>>> +             return NETDEV_TX_BUSY;
>>>> +     }
>>>> +
>>>> +     if (xgene_enet_setup_tx_desc(tx_ring, skb))
>>>> +             return NETDEV_TX_OK;
>>>
>>> If you return NETDEV_TX_OK, it is your responsibility to deal with the
>>> SKB, because you own it.
>>>
>>> In particular, you have to free the packet.
>>
>> skb freeing happens in xgene_enet_tx_completion().
>
> You're not queueing up the packet when DMA mapping the packet fails,
> which is the only condition that causes xgene_enet_setup_tx_desc() to
> return an error, so xgene_enet_tx_completion() will not be called.
>
> Can you really not see this?

I am sorry I missed that.  I will fix this.
