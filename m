From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v6 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Tue, 17 Jun 2014 13:07:42 -0700
Message-ID: <CAKh23F=AexThFD8Oqt-UxyBU1Ai9AfZfP4KpPTzQLXa0WE8Vwg@mail.gmail.com>
References: <1402964326-11147-1-git-send-email-isubramanian@apm.com>
	<1402964326-11147-5-git-send-email-isubramanian@apm.com>
	<20140616.214247.1154200670003936158.davem@davemloft.net>
	<CAKh23F=2undAW=nWibOreAM8DJiQKpLx=OboCX=fNZE+OU=AbA@mail.gmail.com>
	<CAGVrzcYWecdwSmHux6yz1M5Nz849BV-sBe8DmnJWV+T8PetTvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	netdev <netdev@vger.kernel.org>, patches <patches@apm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jcm@redhat.com" <jcm@redhat.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Ravi Patel <rapatel@apm.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcYWecdwSmHux6yz1M5Nz849BV-sBe8DmnJWV+T8PetTvw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2014 at 12:24 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-06-17 12:21 GMT-07:00 Iyappan Subramanian <isubramanian@apm.com>:
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
> I have not looked at what xgenet_enet_setup_tx_desc() does, but
> David's point is that, if this function fails and has not yet been
> able to queue the SKB for transmission at the HW, you should make sure
> that you free the SKB. Is xgene_enet_tx_completion() called if the
> driver failed to prepare a descriptor for a SKB?

Thanks for the explanation.  I will free up skb when
xgene_enet_setup_tx_desc() fails
and submit the next patch shortly.

> --
> Florian
