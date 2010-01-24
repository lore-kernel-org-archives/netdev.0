From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in	vlan_skb_recv
 - probably introduced by commit	9793241fe92f7d9303fb221e43fc598eb065f267
Date: Sun, 24 Jan 2010 17:27:39 +0100
Message-ID: <4B5C74FB.6030308@gmail.com>
References: <20100123165657.187c11e4@neptune.home> <20100123223132.0e62d8cb@neptune.home> <4B5C4E5E.2010507@gmail.com> <20100124160228.366f4e72@neptune.home> <20100124162549.2b39b222@neptune.home> <20100124162523.GC11037@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?QnJ1bm8gUHLDqW1vbnQ=?= <bonbons@linux-vserver.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754036Ab0AXQ1q@vger.kernel.org>
In-Reply-To: <20100124162523.GC11037@hack>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 24/01/2010 17:25, Am=C3=A9rico Wang a =C3=A9crit :
> On Sun, Jan 24, 2010 at 04:25:49PM +0100, Bruno Pr=C3=A9mont wrote:
>> On Sun, 24 January 2010 Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> Le 23/01/2010 22:31, Bruno Pr=C3=A9mont a =C3=A9crit :
>>>>> Above part of code did change between 2.6.32 and 2.6.33-rc5 with
>>>>> commit 9793241fe92f7d9303fb221e43fc598eb065f267 (vlan: Precise RX
>>>>> stats accounting)
>>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommitdiff;h=3D9793241fe92f7d9303fb221e43fc598eb065f267
>>>>
>>>> Reverting just that commit gets the system running correctly.
>>>>
>>>> Bruno
>>>
>>> I have no idea how this patch can break vlan networking.
>>>
>>> Your disassembly and .config seems to show your machine is not SMP
>>
>> Exact
>>
>>> Maybe something is broken on UP and alloc_percpu() ?
>>
>> Apparently not, see below and previous mail
>>
>>> Could you add a debug in vlan_dev_init()
>>
>> In addition to previous mail, I'm also dumping the result of
>> vlan_dev_info(dev) shows that the returned pointer is not the same
>> during vlan_dev_init() and vlan_skb_recv() ...
>>
>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>> index b788978..f370ce1 100644
>> --- a/net/8021q/vlan_dev.c
>> +++ b/net/8021q/vlan_dev.c
>> @@ -165,8 +165,11 @@ int vlan_skb_recv(struct sk_buff *skb, struct n=
et_device *dev,
>>
>>        rx_stats =3D per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
>>                               smp_processor_id());
>=20
>=20
> I am thinking if vlan_dev_info(dev) here should be
> vlan_dev_info(skb->dev)...
>=20
>=20

Yes, I came to same conclusion :)

Thanks
