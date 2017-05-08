From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3 net-next 01/11] net: stmmac: prepare dma op mode config
 for multiple queues
Date: Mon, 8 May 2017 13:12:24 +0300
Message-ID: <CAHp75VcO13o0BgZ75Ssxav2jwP_g+WXLjob8x5QTB6Mdoynpzg@mail.gmail.com>
References: <cover.1489575025.git.jpinto@synopsys.com> <efde5ec3d6873d0b2ad5b806f230f5804257915d.1489575025.git.jpinto@synopsys.com>
 <de6d5aa6-250b-e583-3f24-aee13e6b7ff8@siemens.com> <CAHp75Vfe0pXTEvdt7Z3-DgMTFdC5B3106ubj_D+_ng0vNCUaRA@mail.gmail.com>
 <96c988c8-2d4a-33df-0d20-cc8adac3b01c@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jan Kiszka <jan.kiszka@siemens.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <96c988c8-2d4a-33df-0d20-cc8adac3b01c@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 8, 2017 at 12:54 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote=
:
> Hi Andy and Jan,
>
> =C3=80s 10:36 AM de 5/8/2017, Andy Shevchenko escreveu:
>> On Mon, May 8, 2017 at 9:56 AM, Jan Kiszka <jan.kiszka@siemens.com> wrot=
e:
>>> On 2017-03-15 12:04, Joao Pinto wrote:
>>>> This patch prepares DMA Operation Mode configuration for multiple queu=
es.
>>>> The work consisted on breaking the DMA operation Mode configuration fu=
nction
>>>> into RX and TX scope and adapting its mechanism in stmmac_main.
>>
>>> Starting with this patch, the stmmac-based network adapters of the Inte=
l
>>> Quark SoC stop working. I'm getting an IP via DHCP, I can ping, but TCP
>>> connections can no longer be established.

>> JFYI: With today's linux-next when _kexec:ed_ kernel boots I tried and
>> got the following:
>>
>>
>> # ip a s
>> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
>>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>>    inet 127.0.0.1/8 scope host lo
>>       valid_lft forever preferred_lft forever
>>    inet6 ::1/128 scope host
>>       valid_lft forever preferre[  130.403995] random: fast init done
>> d_lft forever
>> 2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
>>    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
>>    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>> 4: sit0@NONE: <NOARP> mtu 1480 qdisc noop qlen 1000
>>    link/sit 0.0.0.0 brd 0.0.0.0
>> # udhcpc -i eth0
>> udhcpc: started, v1.26.2
>> [  140.825131] stmmaceth 0000:00:14.6 eth0: device MAC address 98:4f:ee:=
05:ac:47
>> [  140.834304] Generic PHY stmmac-a6:01: attached PHY driver [Generic
>> PHY] (mii_bus:phy_addr=3Dstmmac-a6:01, irq=3D-1)
>> [  140.930871] stmmaceth 0000:00:14.6 eth0: IEEE 1588-2008 Advanced
>> Timestamp supported
>> [  140.941109] stmmaceth 0000:00:14.6 eth0: registered PTP clock
>> [  140.953626] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>> udhcpc: sending discover
>> [  142.979557] stmmaceth 0000:00:14.6 eth0: Link is Up - 100Mbps/Full
>> - flow control off
>> [  142.988756] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>> [  142.998810] BUG: unable to handle kernel NULL pointer dereference at =
  (null)
>> [  143.006193] IP: stmmac_xmit+0xf1/0x1080
>> [  143.010168] *pde =3D 00000000
>> [  143.010177]
>> [  143.014762] Oops: 0002 [#1]
>> [  143.017672] Modules linked in: at24 nvmem_core pwm_pca9685
>> [  143.023338] CPU: 0 PID: 0 Comm: swapper Not tainted 4.11.0-next-20170=
508+ #2
>> [  143.030539] task: c8533580 task.stack: c852c000
>> [  143.035237] EIP: stmmac_xmit+0xf1/0x1080
>> [  143.039302] EFLAGS: 00010216 CPU: 0
>> [  143.042915] EAX: 00000000 EBX: 00000050 ECX: 00000000 EDX: ceb6a0c0
>> [  143.049326] ESI: 00000000 EDI: cdd16000 EBP: cdc25d70 ESP: cdc25d20
>> [  143.055735]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>> [  143.061271] CR0: 80050033 CR2: 00000000 CR3: 0eb5c000 CR4: 00100010
>> [  143.067671] Call Trace:
>> [  143.070238]  <SOFTIRQ>
>> [  143.072763]  dev_hard_start_xmit+0x7c/0x1a0
>> [  143.077120]  sch_direct_xmit+0xf0/0x120
>> [  143.081130]  __dev_queue_xmit+0x181/0x430
>> [  143.085311]  ? eth_commit_mac_addr_change+0x20/0x20
>> [  143.090362]  dev_queue_xmit+0xa/0x10
>> [  143.094100]  neigh_resolve_output+0xdb/0x190
>> [  143.098561]  ip6_finish_output2+0x184/0x500
>> [  143.102945]  ip6_finish_output+0x91/0xe0
>> [  143.107057]  ? ip6_finish_output+0x91/0xe0
>> [  143.111338]  ip6_output+0x36/0x110
>> [  143.114924]  ? ip6_fragment+0xb00/0xb00
>> [  143.118935]  mld_sendpack+0x191/0x2b0
>> [  143.122769]  ? mld_newpack+0xda/0x180
>> [  143.126598]  ? ipv6_icmp_sysctl_init+0x30/0x30
>> [  143.131224]  mld_ifc_timer_expire+0x158/0x240
>> [  143.135756]  ? find_next_bit+0xa/0x10
>> [  143.139584]  ? mld_dad_timer_expire+0x50/0x50
>> [  143.144112]  call_timer_fn+0x2a/0xf0
>> [  143.147862]  ? mld_dad_timer_expire+0x50/0x50
>> [  143.152395]  run_timer_softirq+0x158/0x300
>> [  143.156668]  ? file_free_rcu+0x1e/0x30
>> [  143.160589]  __do_softirq+0xc4/0x200
>> [  143.164341]  ? __hrtimer_tasklet_trampoline+0x30/0x30
>> [  143.169575]  do_softirq_own_stack+0x1e/0x30
>> [  143.173902]  </SOFTIRQ>
>> [  143.176502]  irq_exit+0x95/0xa0
>> [  143.179812]  smp_apic_timer_interrupt+0x31/0x40
>> [  143.184530]  apic_timer_interrupt+0x32/0x40
>> [  143.188889] EIP: default_idle+0xc/0x70
>> [  143.192774] EFLAGS: 00000246 CPU: 0
>> [  143.196386] EAX: 00000000 EBX: 00000000 ECX: 00000001 EDX: 00000000
>> [  143.202795] ESI: 00000000 EDI: c8533580 EBP: c852df54 ESP: c852df4c
>> [  143.209205]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>> [  143.214780]  arch_cpu_idle+0x9/0x10
>> [  143.218446]  default_idle_call+0x17/0x30
>> [  143.222551]  do_idle+0xed/0x130
>> [  143.225873]  cpu_startup_entry+0x15/0x20
>> [  143.229965]  rest_init+0x5c/0x60
>> [  143.233370]  start_kernel+0x313/0x318
>> [  143.237221]  i386_start_kernel+0x98/0x9c
>> [  143.241315]  startup_32_smp+0x16b/0x16d
>> [  143.245289] Code: 84 45 06 00 00 c1 e2 05 03 94 c7 9c 09 00 00 89
>> 55 b0 8b 45 c8 8b 75 bc 8b 55 d8 8d 1c 80 89
>> 75 e4 c1 e3 03 8b 84 1f a4 09 00 00 <89> 14 b0 8b 87 40 0d 00 00 8b 40
>> 24 85 c0 89 45 b8 0f 85 68 02
>> [  143.264746] EIP: stmmac_xmit+0xf1/0x1080 SS:ESP: 0068:cdc25d20
>> [  143.270727] CR2: 0000000000000000
>> [  143.274175] ---[ end trace 79da8ef70f8b98d7 ]---
>> [  143.278925] Kernel panic - not syncing: Fatal exception in interrupt
>> [  143.285433] Kernel Offset: 0x6a00000 from 0xc1000000 (relocation
>> range: 0xc0000000-0xd05effff)
>> [  143.294268] ---[ end Kernel panic - not syncing: Fatal exception in i=
nterrupt
>>
>>
>
> Are you using the same version of Ethernet IP, 10/100?

I'm running on Intel Galileo Gen2 board (v4.11 by the way works fine
with direct boot from SD card)

> Could you please verify if the crash you are experiencing is this place?
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_main.c#n2956
>
> I would say that for rather old IPs, the napi is not capable of giving a =
valid
> queue number. Could you please print the queue index returned by this lin=
e?
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_main.c#n2948

--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2953,7 +2953,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff
*skb, struct net_device *dev)
       unsigned int enh_desc;
       unsigned int des;

+       pr_info("%s <<< 1: priv %p, queue: %u\n", __func__, priv, queue);
       tx_q =3D &priv->tx_queue[queue];
+       pr_info("%s <<< 2: priv %p, queue: %u tx_q: %p\n", __func__,
priv, queue, tx_q);


[  101.591040] stmmac_xmit <<< 1: priv cdd1c4c0, queue: 7
[  101.596377] stmmac_xmit <<< 2: priv cdd1c4c0, queue: 7 tx_q: cdd1caac


Also noticed warning that have to be addressed:

drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2504:49: warning:
incorrect type in argument 1 (different address spaces)
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2504:49:    expected
void [noderef] <asn:2>*ioaddr
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2504:49:    got
struct mac_device_info *hw

drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function
=E2=80=98init_dma_rx_desc_rings=E2=80=99:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1274:15: warning:
comparison of
unsigned expression >=3D 0 is always true [-Wtype-limits]
 while (queue >=3D 0) {
              ^~

--=20
With Best Regards,
Andy Shevchenko
