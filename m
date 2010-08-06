From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [GIT] Networking
Date: Thu, 05 Aug 2010 21:49:45 -0700
Message-ID: <4C5B9469.3080409@kernel.org>
References: <20100803.203814.59697285.davem@davemloft.net> 	<AANLkTimxv1y3QJ7s+ghi1FFCcwnUVWT1n6dvT-NNN=Oo@mail.gmail.com> 	<AANLkTinU4+tcm2O_BVBFkHSdnx7JEPtM4sw_s--qdUKC@mail.gmail.com> <AANLkTi=3dVWKtgL2A=4xm_1VSk64--3Zk_fQBYUdAAn+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=3dVWKtgL2A=4xm_1VSk64--3Zk_fQBYUdAAn+@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/05/2010 07:15 PM, Linus Torvalds wrote:
> On Thu, Aug 5, 2010 at 7:04 PM, Yinghai Lu <yinghai@kernel.org> wrote=
:
>>
>>  CC      drivers/net/ixgbe/ixgbe_main.o
>> drivers/net/ixgbe/ixgbe_main.c: In function =91ixgbe_select_queue=92=
:
>> drivers/net/ixgbe/ixgbe_main.c:6159: error: =91struct ixgbe_fcoe=92 =
has no member named =91up=92
>=20
> Hmm. You must have some other version of that file than I do. Line
> 6159 is in ixgbe_init_module() in my source tree.
>=20
>                  Linus

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
blob;f=3Ddrivers/net/ixgbe/ixgbe_main.c;h=3D7d6a415bcf885633999e10ed795=
df49876d6c47e;hb=3DHEAD

6146 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_bu=
ff *skb)
6147 {
6148         struct ixgbe_adapter *adapter =3D netdev_priv(dev);
6149         int txq =3D smp_processor_id();
6150
6151 #ifdef IXGBE_FCOE
6152         if ((skb->protocol =3D=3D htons(ETH_P_FCOE)) ||
6153             (skb->protocol =3D=3D htons(ETH_P_FIP))) {
6154                 if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
6155                         txq &=3D (adapter->ring_feature[RING_F_FCO=
E].indices - 1);
6156                         txq +=3D adapter->ring_feature[RING_F_FCOE=
].mask;
6157                         return txq;
6158                 } else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED=
) {
6159                         txq =3D adapter->fcoe.up;
6160                         return txq;
6161                 }
6162         }
6163 #endif
