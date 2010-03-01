From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbe: Do not allocate too many netdev
 txqueues
Date: Sun, 28 Feb 2010 23:53:20 -0800
Message-ID: <4B8B7270.4080105@intel.com>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>	 <20100226091519.19796.82441.stgit@localhost.localdomain>	 <1267193054.9082.12.camel@edumazet-laptop>	 <1267318956.2052.1.camel@localhost>	 <1267329420.9082.28.camel@edumazet-laptop> <1267428097.2052.772.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22411 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750778Ab0CAHxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 02:53:22 -0500
In-Reply-To: <1267428097.2052.772.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
> On Sat, 2010-02-27 at 20:57 -0700, Eric Dumazet wrote:
>  =20
>> Le samedi 27 f=C3=A9vrier 2010 =C3=A0 17:02 -0800, Peter P Waskiewic=
z Jr a =C3=A9crit :
>>    =20
>>> On Fri, 2010-02-26 at 06:04 -0800, Eric Dumazet wrote:
>>>      =20
>>>> Le vendredi 26 f=C3=A9vrier 2010 =C3=A0 01:15 -0800, Jeff Kirsher =
a =C3=A9crit :
>>>>        =20
>>>>> +	if (ii->mac =3D=3D ixgbe_mac_82598EB)
>>>>> +		indices =3D min_t(unsigned int, indices, IXGBE_MAX_RSS_INDICES=
);
>>>>> +	else
>>>>> +		indices =3D min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICE=
S);
>>>>> +
>>>>> +	indices =3D max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES)=
;
>>>>> +#ifdef IXGBE_FCOE
>>>>> +	indices +=3D min_t(unsigned int, num_possible_cpus(),
>>>>> +			 IXGBE_MAX_FCOE_INDICES);
>>>>> +#endif
>>>>> +	indices =3D min_t(unsigned int, indices, MAX_TX_QUEUES);
>>>>> +	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indi=
ces);
>>>>>  	if (!netdev) {
>>>>>  		err =3D -ENOMEM;
>>>>>  		goto err_alloc_etherdev;
>>>>>
>>>>>          =20
>>>> Thanks Jeff, but what is the reason for limiting to MAX_TX_QUEUES =
?
>>>> Is it a hardware issue ?
>>>>
>>>>        =20
>>> MAX_TX_QUEUES is 128, which is the maximum the 82599 device support=
s in
>>> hardware (82598 supports 32 Tx queues).  I'm not sure why you'd eve=
r
>>> want to have more Tx queues than what you have in the network devic=
e.
>>>      =20
>> I was not sure MAX_TX_QUEUES capping was still necessary after the
>> block :
>>
>> if (ii->mac =3D=3D ixgbe_mac_82598EB)
>>           indices =3D min_t(unsigned int, indices, IXGBE_MAX_RSS_IND=
ICES);
>> else
>>           indices =3D min_t(unsigned int, indices,
>> IXGBE_MAX_FDIR_INDICES);
>>
>> indices =3D max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES);
>> #ifdef IXGBE_FCOE
>> 	indices +=3D min_t(unsigned int, num_possible_cpus(),
>>                     IXGBE_MAX_FCOE_INDICES);
>> #endif
>>
>> So I asked to be sure that MAX_TX_QUEUES was not a leftover from the
>> previous default allocation.
>>
>> Thanks
>>    =20
>
> I see what you're getting at now.  The most we could have from this
> codepath is 72 indices for 82599, and 24 for 82598, so yeah, this is
> probably unneeded.
>
> We can get the patch cleaned up.
>
> Cheers,
> -PJ
>
>  =20
Thanks for catching this.  I'll submit another patch to clean this up. =
=20
Additionally, we can probably remove MAX_TX_QUEUES all together and use=
=20
the above values instead.  No reason to have a tx_ring array larger the=
n=20
we are ever going to use.

thanks
john.

