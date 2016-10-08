From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: tg3 BUG: spinlock lockup suspected
Date: Sat, 8 Oct 2016 21:30:47 +0530
Message-ID: <CAMet4B7r-aVXLrHGnCUqXtV6OxXJkuy=qi3XZRe5HtTZSTfKrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        sparclinux@vger.kernel.org,
        Linux Kernel list <linux-kernel@vger.kernel.org>
To: Meelis Roos <mroos@linux.ee>
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 8, 2016 at 10:15 PM, Meelis Roos <mroos@linux.ee> wrote:
>> That did not go well - bisect found the following commit but that does
>> not seem to be related at all. So probably the reproducibility is not
>> 100% but more random.
>
> Now I reproduced the bug even with 4.7-rc1 so it is older than 4.7. Will
> test further.
>
Thanks for reporting this. We will look into this.
Any specific steps to reproduce this?
>>
>>
>> 4c5773f9f5462dcb372857813918bbfe8c0cdcdd is the first bad commit
>> commit 4c5773f9f5462dcb372857813918bbfe8c0cdcdd
>> Author: Krzysztof Kozlowski <krzk@kernel.org>
>> Date:   Sat May 28 11:54:12 2016 +0200
>>
>>     dt-bindings: clock: Add license and reformat Exynos5410 clock IDs
>>
>>     Add license and copyrights (file introduced in 2014) to header with
>>     Exynos5410 clock IDs. Additionally reformat it to improve readability.
>>
>>     Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>
>>     Acked-by: Stephen Boyd <sboyd@codeaurora.org>
>>     Reviewed-by: Javier Martinez Canillas <javier@osg.samsung.com>
>>     Signed-off-by: Sylwester Nawrocki <s.nawrocki@samsung.com>
>>
>> :040000 040000 acbd432e11366a8eb8775942bc7b8caa476226e2 08e3a3f98c3d4fa2a93123c3f21b2847c06b4665 M      include
>>
>>
>> The whiole bisect log seems to dig around in unrelated places so at best
>> it just narrows the window by adding some known-bad data points.
>>
>> git bisect start
>> # good: [523d939ef98fd712632d93a5a2b588e477a7565e] Linux 4.7
>> git bisect good 523d939ef98fd712632d93a5a2b588e477a7565e
>> # bad: [ef0e1ea8856bed6ff8394d3dfe77f2cab487ecea] Merge tag 'arc-4.8-rc4-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/vgupta/arc
>> git bisect bad ef0e1ea8856bed6ff8394d3dfe77f2cab487ecea
>> # good: [e0b3f595d13b3e9ce9cdf53935e7f304c04b5b2b] affs ->d_compare(): don't bother with ->d_inode
>> git bisect good e0b3f595d13b3e9ce9cdf53935e7f304c04b5b2b
>> # bad: [77a87824ed676ca8ff8482e4157d3adb284fd381] clocksource/drivers/clps_711x: fixup for "ARM: clps711x:
>> git bisect bad 77a87824ed676ca8ff8482e4157d3adb284fd381
>> # bad: [27acbec338113a75b9d72aeb53149a3538031dda] Merge git://www.linux-watchdog.org/linux-watchdog
>> git bisect bad 27acbec338113a75b9d72aeb53149a3538031dda
>> # bad: [7f155c702677d057d03b192ce652311de5434697] Merge tag 'nfs-for-4.8-1' of git://git.linux-nfs.org/projects/trondmy/linux-nfs
>> git bisect bad 7f155c702677d057d03b192ce652311de5434697
>> # good: [797cee982eef9195736afc5e7f3b8f613c41d19a] Merge branch 'stable-4.8' of git://git.infradead.org/users/pcmoore/audit
>> git bisect good 797cee982eef9195736afc5e7f3b8f613c41d19a
>> # bad: [1056c9bd2702ea1bb79abf9bd1e78c578589d247] Merge tag 'clk-for-linus-4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/clk/linux
>> git bisect bad 1056c9bd2702ea1bb79abf9bd1e78c578589d247
>> # bad: [1ff435d3571199a799ba6ccfe05544dcd21b9fb3] Merge branch 'clk-st-critical' into clk-next
>> git bisect bad 1ff435d3571199a799ba6ccfe05544dcd21b9fb3
>> # bad: [0e4504470667d355b53ca3c9802fdd2120c9f946] clk: samsung: exynos5433: Add CLK_IGNORE_UNUSED flag to PCIE device
>> git bisect bad 0e4504470667d355b53ca3c9802fdd2120c9f946
>> # bad: [880c81b3b6604a004d56b5975c8bed47276e8bf6] clk: samsung: exynos5440: Constify all clock initializers
>> git bisect bad 880c81b3b6604a004d56b5975c8bed47276e8bf6
>> # bad: [b3a96eed8e84780d300b79b58047ea277ba358b7] clk: samsung: exynos3250: Move platform driver and of_device_id to init section
>> git bisect bad b3a96eed8e84780d300b79b58047ea277ba358b7
>> # bad: [4528dd8ed477bf202bd33ee48d38d656672d37f8] dt-bindings: clock: Add watchdog and SSS clock IDs to Exynos5410
>> git bisect bad 4528dd8ed477bf202bd33ee48d38d656672d37f8
>> # bad: [5cd3535a27a7cf8fc4070b499d66e419e7e72b61] dt-bindings: clock: Add PWM and USB clock IDs to Exynos5410
>> git bisect bad 5cd3535a27a7cf8fc4070b499d66e419e7e72b61
>> # bad: [4c5773f9f5462dcb372857813918bbfe8c0cdcdd] dt-bindings: clock: Add license and reformat Exynos5410 clock IDs
>> git bisect bad 4c5773f9f5462dcb372857813918bbfe8c0cdcdd
>> # first bad commit: [4c5773f9f5462dcb372857813918bbfe8c0cdcdd] dt-bindings: clock: Add license and reformat Exynos5410 clock IDs
>>
>>
>> >
>> > [   74.123859] tg3.c:v3.137 (May 11, 2014)
>> > [   74.123880] PCI: Enabling device: (0000:00:02.0), cmd 2
>> > [   74.315794] tg3 0000:00:02.0 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
>> > [   74.656152] tg3 0000:00:02.0 eth0: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:85
>> > [   74.656160] tg3 0000:00:02.0 eth0: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
>> > [   74.656167] tg3 0000:00:02.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
>> > [   74.656172] tg3 0000:00:02.0 eth0: dma_rwctrl[763f0000] dma_mask[32-bit]
>> > [   74.656322] PCI: Enabling device: (0000:00:02.1), cmd 2
>> > [   74.845325] tg3 0000:00:02.1 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
>> > [   75.184539] tg3 0000:00:02.1 eth1: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:86
>> > [   75.184546] tg3 0000:00:02.1 eth1: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
>> > [   75.184551] tg3 0000:00:02.1 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
>> > [   75.184557] tg3 0000:00:02.1 eth1: dma_rwctrl[763f0000] dma_mask[32-bit]
>> > [   75.184708] PCI: Enabling device: (0003:00:02.0), cmd 2
>> > [   75.375322] tg3 0003:00:02.0 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
>> > [   75.714681] tg3 0003:00:02.0 eth2: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:87
>> > [   75.714688] tg3 0003:00:02.0 eth2: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
>> > [   75.714694] tg3 0003:00:02.0 eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
>> > [   75.714699] tg3 0003:00:02.0 eth2: dma_rwctrl[763f0000] dma_mask[32-bit]
>> > [   75.714819] PCI: Enabling device: (0003:00:02.1), cmd 2
>> > [   75.905278] tg3 0003:00:02.1 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
>> > [   76.244470] tg3 0003:00:02.1 eth3: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:88
>> > [   76.244477] tg3 0003:00:02.1 eth3: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
>> > [   76.244482] tg3 0003:00:02.1 eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
>> > [   76.244488] tg3 0003:00:02.1 eth3: dma_rwctrl[763f0000] dma_mask[32-bit]
>> > [   83.643317] tg3 0000:00:02.0 eth0: No firmware running
>> > [...]
>> > [   83.716570] BUG: spinlock lockup suspected on CPU#0, dhclient/1014
>> > [   83.797819]  lock: 0xfff000123c8e4a08, .magic: dead4ead, .owner: ip/1001, .owner_cpu: 1
>> > [   83.903130] CPU: 0 PID: 1014 Comm: dhclient Not tainted 4.8.0 #4
>> > [   83.982129] Call Trace:
>> > [   84.014160]  [00000000004b7220] spin_dump+0x60/0xa0
>> > [   84.078203]  [00000000004b73a0] do_raw_spin_lock+0xa0/0x120
>> > [   84.106344] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>> > [   84.107193] ip (1001) used greatest stack depth: 2168 bytes left
>> > [   84.306955]  [000000000092c0d0] _raw_spin_lock_bh+0x30/0x40
>> > [   84.380188]  [00000000100822cc] tg3_get_stats64+0xc/0x80 [tg3]
>> > [   84.456885]  [00000000007fac8c] dev_get_stats+0x2c/0xc0
>> > [   84.525506]  [000000000081a4e8] dev_seq_printf_stats+0x8/0xe0
>> > [   84.600986]  [000000000081a5e4] dev_seq_show+0x24/0x40
>> > [   84.668467]  [00000000005cb6c4] seq_read+0x2c4/0x440
>> > [   84.733656]  [000000000060b97c] proc_reg_read+0x3c/0x80
>> > [   84.802282]  [00000000005a219c] __vfs_read+0x1c/0x140
>> > [   84.868613]  [00000000005a2310] vfs_read+0x50/0x100
>> > [   84.932662]  [00000000005a265c] SyS_read+0x3c/0xa0
>> > [   84.995573]  [00000000004061d4] linux_sparc_syscall32+0x34/0x60
>> > [   85.073748] * CPU[  0]: TSTATE[00000044f0001a22] TPC[00000000f79a16b0] TNPC[00000000f79a16b4] TASK[dhclient:1014]
>> > [   85.208732]              TPC[f79a16b0] O7[f79405c8] I7[0] RPC[0]
>> > [   85.287633]   CPU[  1]: TSTATE[0000004480001605] TPC[00000000004b26f0] TNPC[00000000004d0b0c] TASK[swapper/1:0]
>> > [   85.420338]              TPC[trace_hardirqs_off+0x10/0x20] O7[rcu_idle_enter+0x64/0xa0] I7[cpu_startup_entry+0x1b0/0x240] RPC[rest_init+0x178/0x1a0]
>> > [   85.664600] tg3 0000:00:02.0 eth0: Link is up at 100 Mbps, full duplex
>> > [   85.750515] tg3 0000:00:02.0 eth0: Flow control is off for TX and off for RX
>> > [   85.843994] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>> >
>> >
>>
>>
>
> --
> Meelis Roos (mroos@linux.ee)
