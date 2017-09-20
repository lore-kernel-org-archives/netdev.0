From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 15:09:33 +0200
Message-ID: <245b749e-cf54-b6ef-c9e8-20fb3697892f@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
 <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
 <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
 <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
 <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
 <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
 <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
 <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
 <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
 <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
 <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
 <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
 <1d2a316a-fc71-dae5-cd10-11defc7d2aeb@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:40799 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750997AbdITNLn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 09:11:43 -0400
In-Reply-To: <1d2a316a-fc71-dae5-cd10-11defc7d2aeb@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far path for bisect was:

git bisect start
# bad: [ac7b75966c9c86426b55fe1c50ae148aa4571075] Merge tag 
'pinctrl-v4.13-1' of 
git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl
git bisect bad ac7b75966c9c86426b55fe1c50ae148aa4571075
# good: [e24dd9ee5399747b71c1d982a484fc7601795f31] Merge branch 'next' 
of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security
git bisect good e24dd9ee5399747b71c1d982a484fc7601795f31
# bad: [9cc9a5cb176ccb4f2cda5ac34da5a659926f125f] datapath: Avoid using 
stack larger than 1024.
git bisect bad 9cc9a5cb176ccb4f2cda5ac34da5a659926f125f
# good: [073cf9e20c333ab29744717a23f9e43ec7512a20] Merge branch 
'udp-reduce-cache-pressure'
git bisect good 073cf9e20c333ab29744717a23f9e43ec7512a20
# bad: [8abd5599a520e9f188a750f1bde9dde5fb856230] Merge branch 
's390-net-updates-part-2'
git bisect bad 8abd5599a520e9f188a750f1bde9dde5fb856230
# good: [2fae5d0e647c6470d206e72b5fc24972bb900f70] Merge branch 
'bpf-ctx-narrow'
git bisect good 2fae5d0e647c6470d206e72b5fc24972bb900f70
# good: [41500c3e2a19ffcf40a7158fce1774de08e26ba2] rds: tcp: remove 
cp_outgoing
git bisect good 41500c3e2a19ffcf40a7158fce1774de08e26ba2
# bad: [8917a777be3ba566377be05117f71b93a5fd909d] tcp: md5: add 
TCP_MD5SIG_EXT socket option to set a key address prefix
git bisect bad 8917a777be3ba566377be05117f71b93a5fd909d
# good: [4a6ce2b6f2ecabbddcfe47e7cf61dd0f00b10e36] net: introduce a new 
function dst_dev_put()
git bisect good 4a6ce2b6f2ecabbddcfe47e7cf61dd0f00b10e36
# bad: [a4c2fd7f78915a0d7c5275e7612e7793157a01f2] net: remove 
DST_NOCACHE flag
git bisect bad a4c2fd7f78915a0d7c5275e7612e7793157a01f2
# bad: [ad65a2f05695aced349e308193c6e2a6b1d87112] ipv6: call 
dst_hold_safe() properly
git bisect bad ad65a2f05695aced349e308193c6e2a6b1d87112

No PANIC

# good: [9df16efadd2a8a82731dc76ff656c771e261827f] ipv4: call 
dst_hold_safe() properly
git bisect good 9df16efadd2a8a82731dc76ff656c771e261827f

PANIC

# bad: [1cfb71eeb12047bcdbd3e6730ffed66e810a0855] ipv6: take 
dst->__refcnt for insertion into fib6 tree
git bisect bad 1cfb71eeb12047bcdbd3e6730ffed66e810a0855

PANIC

# bad: [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: mark DST_NOGC 
and remove the operation of dst_free()
git bisect bad b838d5e1c5b6e57b10ec8af2268824041e3ea911
# first bad commit: [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: 
mark DST_NOGC and remove the operation of dst_free()




W dniu 2017-09-20 o 15:05, Paweł Staszewski pisze:
> hmm
>
> But after
>
> b838d5e1c5b6e57b10ec8af2268824041e3ea911 is the first bad commit
> commit b838d5e1c5b6e57b10ec8af2268824041e3ea911
> Author: Wei Wang <weiwan@google.com>
> Date:   Sat Jun 17 10:42:32 2017 -0700
>
>     ipv4: mark DST_NOGC and remove the operation of dst_free()
>
>     With the previous preparation patches, we are ready to get rid of the
>     dst gc operation in ipv4 code and release dst based on refcnt only.
>     So this patch adds DST_NOGC flag for all IPv4 dst and remove the 
> calls
>     to dst_free().
>     At this point, all dst created in ipv4 code do not use the dst gc
>     anymore and will be destroyed at the point when refcnt drops to 0.
>
>     Signed-off-by: Wei Wang <weiwan@google.com>
>     Acked-by: Martin KaFai Lau <kafai@fb.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> :040000 040000 9b7e7fb641de6531fc7887473ca47ef7cb6a11da 
> 831a73b71d3df1755f3e24c0d3c86d7a93fd55e2 M      net
>
>
> Still panic - soo will back to past 3 steps and will try to get again 
> bisect without panic.
>
>
>
> W dniu 2017-09-20 o 14:49, Paweł Staszewski pisze:
>> And the last one
>>
>> git bisect good
>> Bisecting: 1 revision left to test after this (roughly 1 step)
>> [1cfb71eeb12047bcdbd3e6730ffed66e810a0855] ipv6: take dst->__refcnt 
>> for insertion into fib6 tree
>>
>> With this have kernel panic same as always
>>
>> git bisect bad
>> Bisecting: 0 revisions left to test after this (roughly 0 steps)
>> [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: mark DST_NOGC and 
>> remove the operation of dst_free()
>>
>>
>>
>> W dniu 2017-09-20 o 14:23, Paweł Staszewski pisze:
>>> Almost there
>>>
>>> Bisecting: 6 revisions left to test after this (roughly 3 steps)
>>> [ad65a2f05695aced349e308193c6e2a6b1d87112] ipv6: call 
>>> dst_hold_safe() properly
>>>
>>>
>>>
>>> W dniu 2017-09-20 o 13:02, Paweł Staszewski pisze:
>>>> Ok resumed and soo far:
>>>>
>>>> Panic:
>>>>
>>>> # bad: [9cc9a5cb176ccb4f2cda5ac34da5a659926f125f] datapath: Avoid 
>>>> using stack larger than 1024.
>>>> git bisect bad 9cc9a5cb176ccb4f2cda5ac34da5a659926f125f
>>>>
>>>> No panic:
>>>>
>>>> # good: [073cf9e20c333ab29744717a23f9e43ec7512a20] Merge branch 
>>>> 'udp-reduce-cache-pressure'
>>>> git bisect good 073cf9e20c333ab29744717a23f9e43ec7512a20
>>>>
>>>>
>>>> W dniu 2017-09-20 o 12:22, Paweł Staszewski pisze:
>>>>> Soo far bisected and marked:
>>>>>
>>>>> git bisect start
>>>>> # bad: [07dd6cc1fff160143e82cf5df78c1db0b6e03355] Linux 4.13.2
>>>>> git bisect bad 07dd6cc1fff160143e82cf5df78c1db0b6e03355
>>>>> # good: [5d7d2e03e0f01a992e3521b180c3d3e67905f269] Linux 4.12.13
>>>>> git bisect good 5d7d2e03e0f01a992e3521b180c3d3e67905f269
>>>>> # good: [6f7da290413ba713f0cdd9ff1a2a9bb129ef4f6c] Linux 4.12
>>>>> git bisect good 6f7da290413ba713f0cdd9ff1a2a9bb129ef4f6c
>>>>> # bad: [ac7b75966c9c86426b55fe1c50ae148aa4571075] Merge tag 
>>>>> 'pinctrl-v4.13-1' of 
>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl
>>>>> git bisect bad ac7b75966c9c86426b55fe1c50ae148aa4571075
>>>>> # good: [e24dd9ee5399747b71c1d982a484fc7601795f31] Merge branch 
>>>>> 'next' of 
>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security
>>>>> git bisect good e24dd9ee5399747b71c1d982a484fc7601795f31
>>>>> # good: [e24dd9ee5399747b71c1d982a484fc7601795f31] Merge branch 
>>>>> 'next' of 
>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security
>>>>> git bisect good e24dd9ee5399747b71c1d982a484fc7601795f31
>>>>> # good: [e24dd9ee5399747b71c1d982a484fc7601795f31] Merge branch 
>>>>> 'next' of 
>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security
>>>>> git bisect good e24dd9ee5399747b71c1d982a484fc7601795f31
>>>>>
>>>>>
>>>>>
>>>>> W dniu 2017-09-20 o 12:21, Paweł Staszewski pisze:
>>>>>> Ok kernel crashed with different panic that i didnt catch when i 
>>>>>> was doing bisect and now my bisection is broken :)
>>>>>>
>>>>>> git bisect good
>>>>>> Bisecting: 1787 revisions left to test after this (roughly 11 steps)
>>>>>> error: Your local changes to the following files would be 
>>>>>> overwritten by checkout:
>>>>>>         Documentation/00-INDEX
>>>>>>         Documentation/ABI/stable/sysfs-class-udc
>>>>>> Documentation/ABI/testing/configfs-usb-gadget-uac1
>>>>>>         Documentation/ABI/testing/ima_policy
>>>>>>         Documentation/ABI/testing/sysfs-bus-iio
>>>>>> Documentation/ABI/testing/sysfs-bus-iio-meas-spec
>>>>>> Documentation/ABI/testing/sysfs-bus-iio-timer-stm32
>>>>>>         Documentation/ABI/testing/sysfs-class-net
>>>>>> Documentation/ABI/testing/sysfs-class-power-twl4030
>>>>>>         Documentation/ABI/testing/sysfs-class-typec
>>>>>>         Documentation/DMA-API.txt
>>>>>>         Documentation/IRQ-domain.txt
>>>>>>         Documentation/Makefile
>>>>>>         Documentation/PCI/MSI-HOWTO.txt
>>>>>>         Documentation/RCU/00-INDEX
>>>>>> Documentation/RCU/Design/Requirements/Requirements.html
>>>>>>         Documentation/RCU/checklist.txt
>>>>>>         Documentation/admin-guide/README.rst
>>>>>>         Documentation/admin-guide/devices.txt
>>>>>>         Documentation/admin-guide/index.rst
>>>>>>         Documentation/admin-guide/kernel-parameters.txt
>>>>>>         Documentation/admin-guide/pm/cpufreq.rst
>>>>>>         Documentation/admin-guide/pm/intel_pstate.rst
>>>>>>         Documentation/admin-guide/ras.rst
>>>>>>         Documentation/arm/Atmel/README
>>>>>>         Documentation/block/biodoc.txt
>>>>>>         Documentation/conf.py
>>>>>>         Documentation/core-api/assoc_array.rst
>>>>>>         Documentation/core-api/atomic_ops.rst
>>>>>>         Documentation/core-api/index.rst
>>>>>>         Documentation/crypto/asymmetric-keys.txt
>>>>>>         Documentation/dev-tools/index.rst
>>>>>>         Documentation/dev-tools/sparse.rst
>>>>>> Documentation/devicetree/bindings/arm/amlogic.txt
>>>>>> Documentation/devicetree/bindings/arm/atmel-at91.txt
>>>>>>         Documentation/devicetree/bindings/arm/ccn.txt
>>>>>>         Documentation/devicetree/bindings/arm/cpus.txt
>>>>>>         Documentation/devicetree/bindings/arm/gemini.txt
>>>>>> Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
>>>>>> Documentation/devicetree/bindings/arm/keystone/keystone.txt
>>>>>> Documentation/devicetree/bindings/arm/mediatek.txt
>>>>>> Documentation/devicetree/bindings/arm/rockchip.txt
>>>>>> Documentation/devicetree/bindings/arm/shmobile.txt
>>>>>>         Documentation/devicetree/bindings/arm/tegra.txt
>>>>>> Documentation/devicetree/bindings/ata/ahci-fsl-qoriq.txt
>>>>>> Documentation/devicetree/bindings/bus/brcm,gisb-arb.txt
>>>>>> Documentation/devicetree/bindings/clock/brcm,iproc-clocks.txt
>>>>>> Documentation/devicetree/bindings/cpufreq/ti-cpufreq.txt
>>>>>> Documentation/devicetree/bindings/gpio/gpio_atmel.txt
>>>>>> Documentation/devicetree/bindings/iio/adc/amlogic,meson-saradc.txt
>>>>>> Documentation/devicetree/bindings/iio/adc/renesas,gyroadc.txt
>>>>>> Documentation/devicetree/bindings/iio/adc/st,stm32-adc.txt
>>>>>> Documentation/devicetree/bindings/iio/imu/st_lsm6dsx.txt
>>>>>> Documentation/devicetree/bindings/interrupt-controller/allwinner,sunxi-nmi.txt 
>>>>>>
>>>>>> Documentation/devicetree/bindings/interrupt-controller/aspeed,ast2400-vic.txt 
>>>>>>
>>>>>> Documentation/devicetree/bindings/interrupt-controller/mediatek,sysirq.txt 
>>>>>>
>>>>>> Documentation/devicetree/bindings/leds/common.txt
>>>>>>         Documentation/devicetree/bindings/mfd/hi6421.txt
>>>>>> Documentation/devicetree/bindings/mfd/tps65910.txt
>>>>>> Documentation/devicetree/bindings/mmc/fsl-esdhc.txt
>>>>>> Documentation/devicetree/bindings/mmc/k3-dw-mshc.txt
>>>>>> Documentation/devicetree/bindings/mmc/rockchip-dw-mshc.txt
>>>>>> Documentation/devicetree/bindings/mmc/ti-omap-hsmmc.txt
>>>>>> Documentation/devicetree/bindings/mtd/atmel-nand.txt
>>>>>> Documentation/devicetree/bindings/net/dsa/b53.txt
>>>>>> Documentation/devicetree/bindings/net/ethernet.txt
>>>>>>         Documentation/devicetree/bindings/net/macb.txt
>>>>>> Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
>>>>>> Documentation/devicetree/bindings/net/ti,wilink-st.txt
>>>>>> Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt
>>>>>> Documentation/devicetree/bindings/nvmem/rockchip-efuse.txt
>>>>>>         Documentation/devicetree/bindings/opp/opp.txt
>>>>>> Documentation/devicetree/bindings/phy/bcm-ns-usb3-phy.txt
>>>>>> Documentation/devicetree/bindings/phy/brcm-sata-phy.txt
>>>>>> Documentation/devicetree/bindings/phy/meson8b-usb2-phy.txt
>>>>>> Documentation/devicetree/bindings/phy/phy-rockchip-inno-usb2.txt
>>>>>> Documentation/devicetree/bindings/power/rockchip-io-domain.txt
>>>>>> Documentation/devicetree/bindings/power/supply/bq27xxx.txt
>>>>>> Documentation/devicetree/bindings/property-units.txt
>>>>>> Documentation/devicetree/bindings/regulator/regulator.txt
>>>>>>         Documentation/devicetree/bindings/serial/8
>>>>>> error: The following untracked working tree files would be 
>>>>>> overwritten by checkout:
>>>>>>         Documentation/ABI/testing/sysfs-class-net-phydev
>>>>>>         Documentation/DocBook/.gitignore
>>>>>>         Documentation/DocBook/Makefile
>>>>>>         Documentation/DocBook/filesystems.tmpl
>>>>>>         Documentation/DocBook/kernel-hacking.tmpl
>>>>>>         Documentation/DocBook/kernel-locking.tmpl
>>>>>>         Documentation/DocBook/kgdb.tmpl
>>>>>>         Documentation/DocBook/libata.tmpl
>>>>>>         Documentation/DocBook/librs.tmpl
>>>>>>         Documentation/DocBook/lsm.tmpl
>>>>>>         Documentation/DocBook/mtdnand.tmpl
>>>>>>         Documentation/DocBook/networking.tmpl
>>>>>>         Documentation/DocBook/rapidio.tmpl
>>>>>>         Documentation/DocBook/s390-drivers.tmpl
>>>>>>         Documentation/DocBook/scsi.tmpl
>>>>>>         Documentation/DocBook/sh.tmpl
>>>>>>         Documentation/DocBook/stylesheet.xsl
>>>>>>         Documentation/DocBook/w1.tmpl
>>>>>>         Documentation/DocBook/z8530book.tmpl
>>>>>>         Documentation/Makefile.sphinx
>>>>>>         Documentation/RCU/trace.txt
>>>>>> Documentation/devicetree/bindings/i2c/i2c-mt6577.txt
>>>>>> Documentation/devicetree/bindings/misc/allwinner,syscon.txt
>>>>>> Documentation/devicetree/bindings/net/cortina.txt
>>>>>> Documentation/devicetree/bindings/net/dsa/ksz.txt
>>>>>> Documentation/devicetree/bindings/net/dwmac-sun8i.txt
>>>>>> Documentation/devicetree/bindings/net/qca,qca7000.txt
>>>>>> Documentation/devicetree/bindings/power/max8903-charger.txt
>>>>>> Documentation/devicetree/bindings/power_supply/maxim,max14656.txt
>>>>>> Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>>>>> Documentation/devicetree/bindings/timer/moxa,moxart-timer.txt
>>>>>>         Documentation/doc-guide/docbook.rst
>>>>>>         Documentation/networking/tls.txt
>>>>>>         Documentation/prctl/no_new_privs.txt
>>>>>>         Documentation/prctl/seccomp_filter.txt
>>>>>>         Documentation/security/00-INDEX
>>>>>>         Documentation/security/IMA-templates.txt
>>>>>>         Documentation/security/LSM.txt
>>>>>>         Documentation/security/LoadPin.txt
>>>>>>         Documentation/security/SELinux.txt
>>>>>>         Documentation/security/Smack.txt
>>>>>>         Documentation/security/Yama.txt
>>>>>>         Documentation/security/apparmor.txt
>>>>>>         Documentation/security/conf.py
>>>>>>         Documentation/security/credentials.txt
>>>>>>         Documentation/security/keys-ecryptfs.txt
>>>>>>         Documentation/security/keys-request-key.txt
>>>>>> Documentation/security/keys-trusted-encrypted.txt
>>>>>>         Documentation/security/keys.txt
>>>>>>         Documentation/security/self-protection.txt
>>>>>>         Documentation/security/tomoyo.txt
>>>>>>         Documentation/sphinx/convert_template.sed
>>>>>>         Documentation/sphinx/post_convert.sed
>>>>>>         Documentation/sphinx/tmplcvt
>>>>>>         Documentation/usb/typec.rst
>>>>>>         Documentation/usb/usb3-debug-port.rst
>>>>>>         arch/arm/boot/dts/rk1108-evb.dts
>>>>>>         arch/arm/boot/dts/rk1108.dtsi
>>>>>>         arch/arm/boot/dts/tegra20-whistler.dts
>>>>>>         arch/arm/mach-omap2/opp.c
>>>>>>         arch/arm/mach-omap2/pmu.c
>>>>>>         arch/ia64/include/asm/siginfo.h
>>>>>>         arch/m32r/include/uapi/asm/siginfo.h
>>>>>>         arch/microblaze/include/asm/bitops.h
>>>>>>         arch/microblaze/include/asm/bug.h
>>>>>>         arch/microblaze/include/asm/bugs.h
>>>>>>         arch/microblaze/include/asm/div64.h
>>>>>>         arch/microblaze/include/asm/emergency-restart.h
>>>>>>         arch/microblaze/include/asm/fb.h
>>>>>>         arch/microblaze/include/asm/hardirq.h
>>>>>>         arch/microblaze/include/asm/irq_regs.h
>>>>>>         arch/microblaze/include/asm/kdebug.h
>>>>>>         arch/microblaze/include/asm/kmap_types.h
>>>>>>         arch/microblaze/include/asm/linkage.h
>>>>>>         arch/microblaze/include/asm/local.h
>>>>>>         arch/microblaze/include/asm/local64.h
>>>>>>         arch/microblaze/include/asm/parport.h
>>>>>>         arch/microblaze/include/asm/percpu.h
>>>>>>         arch/microblaze/include/asm/serial.h
>>>>>>         arch/microblaze/include/asm/shmparam.h
>>>>>>         arch/microblaze/include/asm/topology.h
>>>>>>         arch/microblaze/include/asm/ucontext.h
>>>>>>         arch/microblaze/include/asm/vga.h
>>>>>>         arch/microblaze/include/asm/xor.h
>>>>>>         arch/microblaze/include/uapi/asm/bitsperlong.h
>>>>>>         arch/microblaze/include/uapi/asm/errno.h
>>>>>>         arch/microblaze/include/uapi/asm/fcntl.h
>>>>>>         arch/microblaze/include/uapi/asm/ioctl.h
>>>>>>         arch/microblaze/include/uapi/asm/ioctls.h
>>>>>>         arch/microblaze/include/uapi/asm/ipcbuf.h
>>>>>>         arch/microblaze/include/uapi/asm/kvm_para.h
>>>>>>         arch/microblaze/include/uapi/asm/mman.h
>>>>>>         arch/microblaze/include/uapi/asm/msgbuf.h
>>>>>>         arch/microblaze/include/uapi/asm/param.h
>>>>>>         arch/microblaze/include/uapi/asm/poll.h
>>>>>>         arch/microblaze/include/uapi/asm/resource.h
>>>>>>         arch/microblaze/include/uapi/asm/sembuf.h
>>>>>>         arch/microblaze/include/uapi/asm/shmbuf.h
>>>>>>         arch/microblaze/include/uapi/asm/siginfo.h
>>>>>>         arch/microblaze/include/uapi/asm/signal.h
>>>>>>         arch/microblaze/includ
>>>>>> Aborting
>>>>>>
>>>>>>
>>>>>>
>>>>>> W dniu 2017-09-20 o 11:45, Paweł Staszewski pisze:
>>>>>>> Ok looks like ending bisection
>>>>>>>
>>>>>>>
>>>>>>> Latest bisected kernel when there is no kernel panic 4.12.0+ 
>>>>>>> (from next)  - but only this warning:
>>>>>>>
>>>>>>> [  309.030019] NETDEV WATCHDOG: enp4s0f0 (ixgbe): transmit queue 
>>>>>>> 0 timed out
>>>>>>> [  309.030034] ------------[ cut here ]------------
>>>>>>> [  309.030040] WARNING: CPU: 35 PID: 0 at dev_watchdog+0xcf/0x139
>>>>>>> [  309.030041] Modules linked in: bonding ipmi_si 
>>>>>>> x86_pkg_temp_thermal
>>>>>>> [  309.030045] CPU: 35 PID: 0 Comm: swapper/35 Not tainted 
>>>>>>> 4.12.0+ #5
>>>>>>> [  309.030046] task: ffff88086d98a000 task.stack: ffffc90003378000
>>>>>>> [  309.030048] RIP: 0010:dev_watchdog+0xcf/0x139
>>>>>>> [  309.030049] RSP: 0018:ffff88087fbc3ea8 EFLAGS: 00010246
>>>>>>> [  309.030050] RAX: 000000000000003d RBX: ffff88046b680000 RCX: 
>>>>>>> 0000000000000000
>>>>>>> [  309.030050] RDX: ffff88087fbd2f01 RSI: 0000000000000000 RDI: 
>>>>>>> ffff88087fbcda08
>>>>>>> [  309.030051] RBP: ffff88087fbc3eb8 R08: 0000000000000000 R09: 
>>>>>>> ffff88087ff80a04
>>>>>>> [  309.030051] R10: 0000000000000000 R11: ffff88086d98a001 R12: 
>>>>>>> 0000000000000000
>>>>>>> [  309.030052] R13: ffff88087fbc3ef8 R14: ffff88086d98a000 R15: 
>>>>>>> ffffffff81c06008
>>>>>>> [  309.030053] FS:  0000000000000000(0000) 
>>>>>>> GS:ffff88087fbc0000(0000) knlGS:0000000000000000
>>>>>>> [  309.030054] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>>>>> [  309.030054] CR2: 00007fba600f6098 CR3: 000000086b955000 CR4: 
>>>>>>> 00000000001406e0
>>>>>>> [  309.030055] Call Trace:
>>>>>>> [  309.030057]  <IRQ>
>>>>>>> [  309.030059]  ? netif_tx_lock+0x79/0x79
>>>>>>> [  309.030062]  call_timer_fn.isra.24+0x17/0x77
>>>>>>> [  309.030063]  run_timer_softirq+0x118/0x161
>>>>>>> [  309.030065]  ? netif_tx_lock+0x79/0x79
>>>>>>> [  309.030066]  ? ktime_get+0x2b/0x42
>>>>>>> [  309.030070]  ? lapic_next_deadline+0x21/0x27
>>>>>>> [  309.030073]  ? clockevents_program_event+0xa8/0xc5
>>>>>>> [  309.030076]  __do_softirq+0xa8/0x19d
>>>>>>> [  309.030078]  irq_exit+0x5d/0x6b
>>>>>>> [  309.030079]  smp_apic_timer_interrupt+0x2a/0x36
>>>>>>> [  309.030082]  apic_timer_interrupt+0x89/0x90
>>>>>>> [  309.030085] RIP: 0010:mwait_idle+0x4e/0x6a
>>>>>>> [  309.030086] RSP: 0018:ffffc9000337be98 EFLAGS: 00000246 
>>>>>>> ORIG_RAX: ffffffffffffff10
>>>>>>> [  309.030087] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 
>>>>>>> 0000000000000000
>>>>>>> [  309.030087] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
>>>>>>> ffff88086d98a000
>>>>>>> [  309.030088] RBP: ffffc9000337be98 R08: ffff88046f8279a0 R09: 
>>>>>>> ffff88046f827040
>>>>>>> [  309.030089] R10: ffff88086d98a000 R11: ffff88086d98a000 R12: 
>>>>>>> 0000000000000000
>>>>>>> [  309.030089] R13: ffff88086d98a000 R14: ffff88086d98a000 R15: 
>>>>>>> ffff88086d98a000
>>>>>>> [  309.030090]  </IRQ>
>>>>>>> [  309.030094]  arch_cpu_idle+0xa/0xc
>>>>>>> [  309.030095]  default_idle_call+0x19/0x1b
>>>>>>> [  309.030102]  do_idle+0xbc/0x196
>>>>>>> [  309.030104]  cpu_startup_entry+0x1d/0x20
>>>>>>> [  309.030105]  start_secondary+0xd8/0xdc
>>>>>>> [  309.030108]  secondary_startup_64+0x9f/0x9f
>>>>>>> [  309.030109] Code: cc 75 bd eb 35 48 89 df c6 05 c3 dc 74 00 
>>>>>>> 01 e8 3a 62 fe ff 44 89 e1 48 89 de 48 89 c2 48 c7 c7 0f 65 a4 
>>>>>>> 81 31 c0 e8 3d 4c b5 ff <0f> ff 48 8b 83 e0 01 00 00 48 89 df ff 
>>>>>>> 50 78 48 8b 05 a0 bc 6a
>>>>>>> [  309.030128] ---[ end trace 9102cb25703ae2d9 ]---
>>>>>>>
>>>>>>>
>>>>>>> I just marked it as good - cause this problem above is differend 
>>>>>>> - and im going to:
>>>>>>>
>>>>>>> git bisect good
>>>>>>> Bisecting: 1787 revisions left to test after this (roughly 11 
>>>>>>> steps)
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> W dniu 2017-09-20 o 10:44, Paweł Staszewski pisze:
>>>>>>>> Trying to make video from ipmi :)
>>>>>>>>
>>>>>>>> with that results:
>>>>>>>>
>>>>>>>> https://bugzilla.kernel.org/attachment.cgi?id=258521
>>>>>>>>
>>>>>>>> catched two more lines where it starts - panic from 4.13.2.
>>>>>>>>
>>>>>>>>
>>>>>>>> Now will try tro do some bisection
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> W dniu 2017-09-20 o 09:58, Paweł Staszewski pisze:
>>>>>>>>> Hi
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> Will try bisecting tonight
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> W dniu 2017-09-20 o 05:24, Eric Dumazet pisze:
>>>>>>>>>> On Wed, 2017-09-20 at 02:06 +0200, Paweł Staszewski wrote:
>>>>>>>>>>> Just checked kernel 4.13.2 and same problem
>>>>>>>>>>>
>>>>>>>>>>> Just after start all 6 bgp sessions - and kernel starts to 
>>>>>>>>>>> learn routes
>>>>>>>>>>> it panic.
>>>>>>>>>>>
>>>>>>>>>>> https://bugzilla.kernel.org/attachment.cgi?id=258509
>>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> Unfortunately we have not enough information from these traces.
>>>>>>>>>>
>>>>>>>>>> Can you get a full stack trace ?
>>>>>>>>>>
>>>>>>>>>> Alternatively, can you bisect ?
>>>>>>>>>>
>>>>>>>>>> Thanks.
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>
>>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>
>
