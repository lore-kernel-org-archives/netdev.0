From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: spinlock bad magic on CPU#1, swapper/1
Date: Wed, 05 Aug 2009 12:02:59 +0200
Message-ID: <4A7958D3.40206@gmail.com>
References: <200908051136.44908.elendil@planet.nl> <200908051150.53301.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: Frans Pop <elendil@planet.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934137AbZHEKD1@vger.kernel.org>
In-Reply-To: <200908051150.53301.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rans Pop a =C3=A9crit :
> On Wednesday 05 August 2009, Frans Pop wrote:
>> Current v2.6.31-rc5-246-g90bc1a6 gives me:
>>
>> BUG: spinlock bad magic on CPU#1, swapper/1
>>  lock: ffff88007e1889c8, .magic: 00000000, .owner: <none>/-1, .owner=
_cpu: 0
>> Pid: 1, comm: swapper Not tainted 2.6.31-rc5 #4=20
>> Call Trace:
>>  [<ffffffff811345e8>] spin_bug+0xa2/0xaa
>>  [<ffffffff8113469e>] _raw_spin_lock+0x23/0x135
>>  [<ffffffff8125664e>] _spin_lock_bh+0x19/0x1e
>>  [<ffffffff811e3702>] alloc_netdev_mq+0x127/0x211
>>  [<ffffffff81433487>] ? netdev_init+0x6a/0xac
>>  [<ffffffff811a81eb>] ? loopback_setup+0x0/0x7b
>>  [<ffffffff8142e718>] loopback_net_init+0x30/0x7a
>>  [<ffffffff811dd62e>] register_pernet_device+0x2b/0x58
>>  [<ffffffff814336bd>] net_dev_init+0x13d/0x19b
>>  [<ffffffff81433580>] ? net_dev_init+0x0/0x19b
>>  [<ffffffff8100905c>] do_one_initcall+0x56/0x12b
>>  [<ffffffff8106f55b>] ? register_irq_proc+0xb0/0xcc
>>  [<ffffffff810e0000>] ? proc_pid_cmdline+0x5a/0xf9
>>  [<ffffffff8140f65d>] kernel_init+0x14d/0x1a3
>>  [<ffffffff8100ca7a>] child_rip+0xa/0x20
>>  [<ffffffff8140f510>] ? kernel_init+0x0/0x1a3
>>  [<ffffffff8100ca70>] ? child_rip+0x0/0x20
>>
>> Error occurs during early boot (between PCI/ACPI init and PnP init).
>=20
> Reverting the following commit fixes it:
> commit a6ac65db2329e7685299666f5f7b6093c7b0f3a0
> Author: Jiri Pirko <jpirko@redhat.com>
> Date:   Thu Jul 30 01:06:12 2009 +0000
>=20
>     net: restore the original spinlock to protect unicast list
>=20
>     There is a path when an assetion in dev_unicast_sync() appears.
>=20
>     igmp6_group_added -> dev_mc_add -> __dev_set_rx_mode ->
>     -> vlan_dev_set_rx_mode -> dev_unicast_sync
>=20
>     Therefore we cannot protect this list with rtnl. This patch resto=
res the
>     original protecting this list with spinlock.
>=20
>     Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>     Tested-by: Meelis Roos <mroos@linux.ee>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> --


Ingo posted a fix=20

http://marc.info/?l=3Dlinux-kernel&m=3D124945666109347&w=3D2
