From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next-2.6] rps: allocate rx queues in register_netdevice
 only
Date: Fri, 24 Sep 2010 09:54:14 -0700
Message-ID: <4C9CD7B6.1070201@intel.com>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>	 <1285273194.7794.24.camel@achroite.uk.solarflarecom.com>	 <1285296505.2380.43.camel@edumazet-laptop>	 <1285298795.2380.54.camel@edumazet-laptop>  <4C9C5E0C.1000200@intel.com> <1285320110.2503.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36546 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753700Ab0IXQyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Sep 2010 12:54:16 -0400
In-Reply-To: <1285320110.2503.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/24/2010 2:21 AM, Eric Dumazet wrote:
> Le vendredi 24 septembre 2010 =C3=A0 01:15 -0700, John Fastabend a =C3=
=A9crit :
>> On 9/23/2010 8:26 PM, Eric Dumazet wrote:
>>>
>>>> Also, I dont understand why we need to restrict
>>>> netif_set_real_num_rx_queues() to lower the count.
>>>> This wastes memory.
>>>>
>>>> Why dont we allocate dev->_rx once we know the real count, not in
>>>> alloc_netdev_mq() but in register_netdevice() ?
>>>>
>>
>> Eric,
>>
>> At least in the TX case we may not "know" until later how many
>> tx_queues we want to use. For example it could change based on
>> enabling/disabling features or available interrupts. So we use
>> num_tx_queues as the max we ever expect to use and then
>> netif_set_real_num_tx_queues() sets the number we want to use.
>>
>> I presume for rx queues there are similar cases where features and
>> available interrupts may determine how many rx queues are needed.
>>
>> Moving the allocation later could help drivers make better max numbe=
r
>> of queue decisions. But, I think we still need the
>> netif_set_num_rx_queues() and netif_set_num_tx_queues(). Although th=
is
>> does end up wasting memory as you pointed out.
>>
>=20
> Note I am not against having netif_set_num_rx_queues() and
> netif_set_num_tx_queues(). My patch was a cleanup, not an alternative=
=2E
>=20
>=20
> If I take a look at sysfs stuff, on a machine with a bnx2 adapter,
> single queue, I get :
>=20
> /sys/class/net/eth0/queues/rx-0/rps_cpus
> /sys/class/net/eth0/queues/rx-0/rps_flow_cnt
> /sys/class/net/eth0/queues/rx-1/rps_cpus
> /sys/class/net/eth0/queues/rx-1/rps_flow_cnt
> /sys/class/net/eth0/queues/rx-2/rps_cpus
> /sys/class/net/eth0/queues/rx-2/rps_flow_cnt
> /sys/class/net/eth0/queues/rx-3/rps_cpus
> /sys/class/net/eth0/queues/rx-3/rps_flow_cnt
> /sys/class/net/eth0/queues/rx-4/rps_cpus
> /sys/class/net/eth0/queues/rx-4/rps_flow_cnt
> /sys/class/net/eth0/queues/rx-5/rps_cpus
> /sys/class/net/eth0/queues/rx-5/rps_flow_cnt
> /sys/class/net/eth0/queues/rx-6/rps_cpus
> /sys/class/net/eth0/queues/rx-6/rps_flow_cnt
> /sys/class/net/eth0/queues/rx-7/rps_cpus
> /sys/class/net/eth0/queues/rx-7/rps_flow_cnt
>=20
> Thats a lot of extra memory and administrator confusion.
>=20
> We all agree :)
>=20
>=20

Thanks for the clarification Eric.
