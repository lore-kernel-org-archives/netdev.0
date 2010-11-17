From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-2.6 PATCH v2] net: zero kobject in rx_queue_release
Date: Tue, 16 Nov 2010 22:01:02 -0800
Message-ID: <4CE36F9E.4070508@intel.com>
References: <20101117054253.8714.24548.stgit@jf-dev1-dcblab> <1289973119.2732.104.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60554 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996Ab0KQGBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 01:01:03 -0500
In-Reply-To: <1289973119.2732.104.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2010 9:51 PM, Eric Dumazet wrote:
> Le mardi 16 novembre 2010 =C3=A0 21:42 -0800, John Fastabend a =C3=A9=
crit :
>> netif_set_real_num_rx_queues() can decrement and increment
>> the number of rx queues. For example ixgbe does this as
>> features and offloads are toggled. Presumably this could
>> also happen across down/up on most devices if the available
>> resources changed (cpu offlined).
>>
>> The kobject needs to be zero'd in this case so that the
>> state is not preserved across kobject_put()/kobject_init_and_add().
>>
>> This resolves the following error report.
>>
>> ixgbe 0000:03:00.0: eth2: NIC Link is Up 10 Gbps, Flow Control: RX/T=
X
>> kobject (ffff880324b83210): tried to init an initialized object, som=
ething is seriously wrong.
>> Pid: 1972, comm: lldpad Not tainted 2.6.37-rc18021qaz+ #169
>> Call Trace:
>>  [<ffffffff8121c940>] kobject_init+0x3a/0x83
>>  [<ffffffff8121cf77>] kobject_init_and_add+0x23/0x57
>>  [<ffffffff8107b800>] ? mark_lock+0x21/0x267
>>  [<ffffffff813c6d11>] net_rx_queue_update_kobjects+0x63/0xc6
>>  [<ffffffff813b5e0e>] netif_set_real_num_rx_queues+0x5f/0x78
>>  [<ffffffffa0261d49>] ixgbe_set_num_queues+0x1c6/0x1ca [ixgbe]
>>  [<ffffffffa0262509>] ixgbe_init_interrupt_scheme+0x1e/0x79c [ixgbe]
>>  [<ffffffffa0274596>] ixgbe_dcbnl_set_state+0x167/0x189 [ixgbe]
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>=20
> I am not sure why you resent it, anyway, I ack it
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Thanks
>=20
>=20

net-next has Tom's changes for queue allocation and freeing. So the net=
-2.6 patch and net-next-2.6 patches are slightly different. I wanted to=
 get the RCU_INIT_POINTER update in both and thought it would be easies=
t for Dave if they applied cleanly on both tree's. Let me know if there=
 is a better way to indicate that here I just used the prefix net and n=
et-next.

Thanks,
John.
