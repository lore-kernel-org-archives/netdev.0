From: Mason <slash.tmp@free.fr>
Subject: Setting link down hangs the kernel
Date: Tue, 10 Jan 2017 15:36:47 +0100
Message-ID: <3ac03634-02fa-6acd-479d-fc475fc45736@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Thomas Gambier <thomas_gambier@sigmadesigns.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:44142 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759057AbdAJOhB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 09:37:01 -0500
Content-Language: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm using kernel v4.9 on a dev board.
I built a small kernel + rootfs with buildroot 2016.11.1
eth0 is driven by drivers/net/ethernet/aurora/nb8800.c

After booting, I just run udhcpc (busybox version)
Then I set the link down, and the kernel hangs.

Here's the console output:

[    1.116707] Freeing unused kernel memory: 3072K (c0600000 - c0900000)
Starting logging: OK
Initializing random number generator... [    1.217335] random: dd: uninitialized urandom read (512 bytes read)
done.
Starting network: OK

Welcome to Buildroot
buildroot login: root
# udhcpc 
udhcpc: started, v1.25.1
udhcpc: sending discover
udhcpc: sending discover
[   13.840512] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
udhcpc: sending discover
udhcpc: sending select for 172.27.64.51
udhcpc: lease of 172.27.64.51 obtained, lease time 604800
deleting routers
adding dns 172.27.0.17
# ip link set dev eth0 down
[   65.520187] nb8800 26000.ethernet eth0: Link is Down
^C^C^C
[   85.790557] sysrq: SysRq : Show backtrace of all active CPUs
[   85.796260] NMI backtrace for cpu 0
[   85.799773] CPU: 0 PID: 866 Comm: ip Not tainted 4.9.0 #143
[   85.805376] Hardware name: Sigma Tango DT
[   85.809405] Backtrace: 
[   85.811893] [<c010ad6c>] (dump_backtrace) from [<c010b00c>] (show_stack+0x18/0x1c)
[   85.819510]  r7:00000000 r6:600c0193 r5:00000000 r4:c0910af4
[   85.825216] [<c010aff4>] (show_stack) from [<c029264c>] (dump_stack+0x84/0xa0)
[   85.832491] [<c02925c8>] (dump_stack) from [<c0295c60>] (nmi_cpu_backtrace+0x98/0xb8)
[   85.840370]  r7:00000000 r6:c010c9e4 r5:00000000 r4:00000000
[   85.846074] [<c0295bc8>] (nmi_cpu_backtrace) from [<c0295d44>] (nmi_trigger_cpumask_backtrace+0xc4/0x17c)
[   85.855696]  r5:00000000 r4:c09032e4
[   85.859304] [<c0295c80>] (nmi_trigger_cpumask_backtrace) from [<c010d3a4>] (arch_trigger_cpumask_backtrace+0x14/0x1c)
[   85.869981]  r9:00000100 r8:00000001 r7:0000006c r6:0000000a r5:c090ac48 r4:c0911458
[   85.877783] [<c010d390>] (arch_trigger_cpumask_backtrace) from [<c02caea4>] (sysrq_handle_showallcpus+0x18/0x20)
[   85.888027] [<c02cae8c>] (sysrq_handle_showallcpus) from [<c02cb5c0>] (__handle_sysrq+0x90/0x12c)
[   85.896958] [<c02cb530>] (__handle_sysrq) from [<c02cb684>] (handle_sysrq+0x28/0x2c)
[   85.904751]  r9:00000100 r8:00000000 r7:0000006c r6:00000061 r5:00000061 r4:0000006c
[   85.912553] [<c02cb65c>] (handle_sysrq) from [<c02de4e4>] (serial8250_rx_chars+0x178/0x1d8)
[   85.920952]  r5:00000061 r4:c094e654
[   85.924557] [<c02de36c>] (serial8250_rx_chars) from [<c02dfe40>] (serial8250_handle_irq+0x8c/0xdc)
[   85.933575]  r10:00000014 r9:cfbea6cc r8:cfbea6c0 r7:600c0193 r6:00000061 r5:000000cc
[   85.941448]  r4:c094e654
[   85.944002] [<c02dfdb4>] (serial8250_handle_irq) from [<c02dff28>] (serial8250_default_handle_irq+0x30/0x44)
[   85.953888]  r7:00000000 r6:00000000 r5:00000000 r4:c094e654
[   85.959588] [<c02dfef8>] (serial8250_default_handle_irq) from [<c02dce6c>] (serial8250_interrupt+0x3c/0xbc)
[   85.969383]  r5:00000000 r4:c094e768
[   85.972993] [<c02dce30>] (serial8250_interrupt) from [<c01582e8>] (__handle_irq_event_percpu+0x40/0x10c)
[   85.982534]  r10:c090c7b5 r9:cfa57c54 r8:cf866a00 r7:00000001 r6:00000014 r5:00000000
[   85.990409]  r4:cfbea680 r3:c02dce30
[   85.994015] [<c01582a8>] (__handle_irq_event_percpu) from [<c01583d8>] (handle_irq_event_percpu+0x24/0x60)
[   86.003730]  r10:ffffffff r9:cfa56000 r8:00000002 r7:00000001 r6:cf866a10 r5:cf866a00
[   86.011602]  r4:cf866a00
[   86.014159] [<c01583b4>] (handle_irq_event_percpu) from [<c0158454>] (handle_irq_event+0x40/0x64)
[   86.023082]  r5:cf866a60 r4:cf866a00
[   86.026686] [<c0158414>] (handle_irq_event) from [<c015bc68>] (handle_level_irq+0xdc/0x118)
[   86.035087]  r7:00000001 r6:cf866a10 r5:cf866a60 r4:cf866a00
[   86.040787] [<c015bb8c>] (handle_level_irq) from [<c015768c>] (generic_handle_irq+0x20/0x30)
[   86.049275]  r7:00000001 r6:00000000 r5:cf802600 r4:00000001
[   86.054976] [<c015766c>] (generic_handle_irq) from [<c02b537c>] (tangox_dispatch_irqs+0x4c/0x58)
[   86.063820] [<c02b5330>] (tangox_dispatch_irqs) from [<c02b5404>] (tangox_irq_handler+0x7c/0xa4)
[   86.072662]  r9:cfa56000 r8:cf802400 r7:00000000 r6:c0903310 r5:cf802600 r4:cf804010
[   86.080458] [<c02b5388>] (tangox_irq_handler) from [<c015768c>] (generic_handle_irq+0x20/0x30)
[   86.089121]  r7:00000010 r6:c0866edc r5:00000000 r4:00000000
[   86.094822] [<c015766c>] (generic_handle_irq) from [<c0157c14>] (__handle_domain_irq+0x94/0xbc)
[   86.103578] [<c0157b80>] (__handle_domain_irq) from [<c010142c>] (gic_handle_irq+0x50/0x7c)
[   86.111984]  r9:cfa56000 r8:00000000 r7:f0701100 r6:cfa57d60 r5:c0903310 r4:f0700100
[   86.119778] [<c01013dc>] (gic_handle_irq) from [<c010bb0c>] (__irq_svc+0x6c/0xa8)
[   86.127303] Exception stack(0xcfa57d60 to 0xcfa57da8)
[   86.132390] 7d60: cfb2f800 00000000 f0026000 00240aff cfb2f800 cfbe1400 00001042 00001003
[   86.140621] 7d80: 00000000 00000000 ffffffff cfa57dbc cfa57dc0 cfa57db0 c0312e8c c0310ad4
[   86.148843] 7da0: 200c0013 ffffffff
[   86.152354]  r7:cfa57d94 r6:ffffffff r5:200c0013 r4:c0310ad4
[   86.158058] [<c0310ac8>] (nb8800_mac_tx) from [<c0312e8c>] (nb8800_stop+0x60/0x84)
[   86.165683] [<c0312e2c>] (nb8800_stop) from [<c033e094>] (__dev_close_many+0x9c/0xc0)
[   86.173558]  r5:cfa57df0 r4:cfb2f800
[   86.177160] [<c033dff8>] (__dev_close_many) from [<c033e1c8>] (__dev_close+0x30/0x48)
[   86.185035]  r5:00000001 r4:cfb2f800
[   86.188639] [<c033e198>] (__dev_close) from [<c0345898>] (__dev_change_flags+0x94/0x138)
[   86.196781] [<c0345804>] (__dev_change_flags) from [<c034595c>] (dev_change_flags+0x20/0x50)
[   86.205273]  r9:00000000 r8:00000000 r7:00000000 r6:cfb2f944 r5:00001003 r4:cfb2f800
[   86.213072] [<c034593c>] (dev_change_flags) from [<c039e8f4>] (devinet_ioctl+0x308/0x67c)
[   86.221303]  r9:00000000 r8:cfa1c20c r7:00000000 r6:cfb2f800 r5:cfa1c200 r4:cfada500
[   86.229098] [<c039e5ec>] (devinet_ioctl) from [<c03a09f8>] (inet_ioctl+0xc4/0xf8)
[   86.236630]  r10:00000000 r9:cfa56000 r8:be97dc80 r7:00008914 r6:be97dc80 r5:00008914
[   86.244502]  r4:c03a0934
[   86.247062] [<c03a0934>] (inet_ioctl) from [<c032a9ec>] (sock_ioctl+0x24c/0x29c)
[   86.254500]  r5:00008914 r4:c03a0934
[   86.258108] [<c032a7a0>] (sock_ioctl) from [<c01db9d0>] (vfs_ioctl+0x28/0x3c)
[   86.265288]  r7:00008914 r6:cfa61900 r5:cf43a0a0 r4:be97dc80
[   86.270989] [<c01db9a8>] (vfs_ioctl) from [<c01dc270>] (do_vfs_ioctl+0x764/0x8b8)
[   86.278523] [<c01dbb0c>] (do_vfs_ioctl) from [<c01dc400>] (SyS_ioctl+0x3c/0x64)
[   86.285881]  r10:00000000 r9:cfa56000 r8:be97dc80 r7:00008914 r6:cfa61900 r5:cfa61900
[   86.293753]  r4:00000003
[   86.296309] [<c01dc3c4>] (SyS_ioctl) from [<c0107260>] (ret_fast_syscall+0x0/0x3c)
[   86.303929]  r9:cfa56000 r8:c0107424 r7:00000036 r6:00000003 r5:00000001 r4:000a15bb
^C^C^C^C^C


Looks like the kernel is wedged in nb8800_mac_tx.

static void nb8800_mac_tx(struct net_device *dev, bool enable)
{
	struct nb8800_priv *priv = netdev_priv(dev);

	while (nb8800_readl(priv, NB8800_TXC_CR) & TCR_EN)
		cpu_relax();

	nb8800_modb(priv, NB8800_TX_CTL1, TX_EN, enable);
}

c0310ac8 <nb8800_mac_tx>:
c0310ac8:       e1a0c00d        mov     ip, sp
c0310acc:       e92dd800        push    {fp, ip, lr, pc}
c0310ad0:       e24cb004        sub     fp, ip, #4
c0310ad4:       e5902530        ldr     r2, [r0, #1328] ; 0x530
c0310ad8:       e5923100        ldr     r3, [r2, #256]  ; 0x100
c0310adc:       e3130001        tst     r3, #1
c0310ae0:       0a000000        beq     c0310ae8 <nb8800_mac_tx+0x20>
c0310ae4:       eafffffa        b       c0310ad4 <nb8800_mac_tx+0xc>
c0310ae8:       e5d23000        ldrb    r3, [r2]
c0310aec:       e6ef3073        uxtb    r3, r3
c0310af0:       e0211003        eor     r1, r1, r3
c0310af4:       e2011001        and     r1, r1, #1
c0310af8:       e0211003        eor     r1, r1, r3
c0310afc:       e1530001        cmp     r3, r1
c0310b00:       089da800        ldmeq   sp, {fp, sp, pc}
c0310b04:       e5c21000        strb    r1, [r2]
c0310b08:       e89da800        ldm     sp, {fp, sp, pc}

If I'm reading the exception stack correctly, the CPU was at c0310ad4,
i.e. it's stuck in the while loop.

Time for me to hit the data sheet, I guess :-(


While investigating this bug, I also hit a different symptom:

# ip link set dev eth0 down
# ip link set dev eth0 up
# [  252.560722] nb8800 26000.ethernet eth0: Link is Down
[  254.587431] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
# ip link set dev eth0 down
[  257.673295] nb8800 26000.ethernet eth0: RX Status FIFO overflow
[  257.773613] nb8800 26000.ethernet eth0: RX Status FIFO overflow
[  257.873807] nb8800 26000.ethernet eth0: RX Status FIFO overflow
[  257.973981] nb8800 26000.ethernet eth0: RX Status FIFO overflow
[  258.074160] nb8800 26000.ethernet eth0: RX Status FIFO overflow
# ip link set dev eth0 up
# [  261.787381] nb8800 26000.ethernet eth0: Link is Down
[  263.814093] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
# ip link set dev eth0 down
[  268.723656] nb8800 26000.ethernet eth0: RX Status FIFO overflow
[  268.823980] nb8800 26000.ethernet eth0: RX Status FIFO overflow
[  268.880451] nb8800 26000.ethernet eth0: Link is Down
^C^C^C^C


Regards.
