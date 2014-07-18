From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 1/2] net: macb: Separate rx and tx ring init function
Date: Fri, 18 Jul 2014 15:45:24 +0530
Message-ID: <53C8F3BC.4060607@gmail.com>
References: <53C8EE60.8020707@gmail.com> <53C8F280.9040507@gmail.com> <53C8F34D.9090503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neil Armstrong <superna9999@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53C8F34D.9090503@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/18/2014 03:43 PM, Neil Armstrong wrote:
> Le 18/07/2014 12:10, Varka Bhadram a =E9crit :
>> On 07/18/2014 03:22 PM, Neil Armstrong wrote:
>>> A single method is called to initialize the TX and RX
>>> rings. Separate the methods into distinct ones for
>>> MACB and GEM context.
>>>
>>> Signed-off-by: Neil Armstrong <narmstrong@neotion.com>
>>> ---
>>>    drivers/net/ethernet/cadence/macb.c |   33 +++++++++++++++++++++=
+++---------
>>>    drivers/net/ethernet/cadence/macb.h |    3 ++-
>>>    2 files changed, 26 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethe=
rnet/cadence/macb.c
>>> index e9daa07..20ad483 100644
>>> --- a/drivers/net/ethernet/cadence/macb.c
>>> +++ b/drivers/net/ethernet/cadence/macb.c
>>> @@ -1219,7 +1219,14 @@ out_err:
>>>    	return -ENOMEM;
>>>    }
>>>   =20
>>> -static void gem_init_rings(struct macb *bp)
>>> +static void gem_init_rx_rings(struct macb *bp)
>>> +{
>>> +	bp->rx_tail =3D bp->rx_prepared_head =3D 0;
>>> +
>>> +	gem_rx_refill(bp);
>>> +}
>>> +
>>> +static void gem_init_tx_rings(struct macb *bp)
>>>    {
>>>    	int i;
>>>   =20
>>> @@ -1229,12 +1236,10 @@ static void gem_init_rings(struct macb *bp)
>>>    	}
>>>    	bp->tx_ring[TX_RING_SIZE - 1].ctrl |=3D MACB_BIT(TX_WRAP);
>>>   =20
>>> -	bp->rx_tail =3D bp->rx_prepared_head =3D bp->tx_head =3D bp->tx_t=
ail =3D 0;
>>> -
>>> -	gem_rx_refill(bp);
>>> +	bp->tx_head =3D bp->tx_tail =3D 0;
>> This is not the preferred way of doing it....
>>
>> multiple assignments should be avoided
> Should I change it ? I only moved the lines, the logic hasn't changed=
=2E
>
Yes. we can change the logic also....  :-)

--=20
Regards,
Varka Bhadram.
