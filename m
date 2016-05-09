From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: bnx2x in 4.6rc7 with FW 7.13.1.0 not present
Date: Mon, 9 May 2016 20:19:38 +0000
Message-ID: <94D0CD8314A33A4D9D801C0FE68B4029639613DA@G4W3202.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
	"Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upgrading a system from kernel 4.2 to 4.6rc7, there is an extra 2 minut=
e
delay while booting due to these problems:

    [   47.977221] bnx2x 0000:04:00.1: Direct firmware load for bnx2x/b=
nx2x-e2-7.13.1.0.fw failed with error -2
    [   48.029997] bnx2x 0000:04:00.1: Falling back to user helper
    [**    ] A start job is running for Network Manager Wait Online (1m=
in 27s / no limit)
    [  108.064132] bnx2x: [bnx2x_init_firmware:13472(eno50)]Can't load =
firmware file bnx2x/bnx2x-e2-7.13.1.0.fw
    [  108.119951] bnx2x: [bnx2x_func_hw_init:5785(eno50)]Error loading=
 firmware
    [  108.156522] bnx2x: [bnx2x_nic_load:2727(eno50)]HW init failed, a=
borting
    [*     ] A start job is running for Network Manager Wait Online (1m=
in 28s / no limit)

These are the versions in /lib/firmware/bnx2x (a RHEL installation):
bnx2x-e2-6.2.9.0.fw    bnx2x-e1-7.8.19.0.fw    bnx2x-e1h-7.8.2.0.fw
bnx2x-e1h-6.2.9.0.fw   bnx2x-e1-7.8.2.0.fw     bnx2x-e2-6.0.34.0.fw
bnx2x-e1-6.2.9.0.fw    bnx2x-e1h-6.0.34.0.fw   bnx2x-e2-6.2.5.0.fw
bnx2x-e1-6.0.34.0.fw   bnx2x-e1h-6.2.5.0.fw    bnx2x-e2-7.0.20.0.fw
bnx2x-e1-6.2.5.0.fw    bnx2x-e1h-7.0.20.0.fw   bnx2x-e2-7.0.23.0.fw
bnx2x-e1-7.0.20.0.fw   bnx2x-e1h-7.0.23.0.fw   bnx2x-e2-7.0.29.0.fw
bnx2x-e1-7.0.23.0.fw   bnx2x-e1h-7.0.29.0.fw   bnx2x-e2-7.10.51.0.fw
bnx2x-e1-7.0.29.0.fw   bnx2x-e1h-7.10.51.0.fw  bnx2x-e2-7.12.30.0.fw
bnx2x-e1-7.10.51.0.fw  bnx2x-e1h-7.12.30.0.fw  bnx2x-e2-7.2.16.0.fw
bnx2x-e1-7.12.30.0.fw  bnx2x-e1h-7.2.16.0.fw   bnx2x-e2-7.2.51.0.fw
bnx2x-e1-7.2.16.0.fw   bnx2x-e1h-7.2.51.0.fw   bnx2x-e2-7.8.17.0.fw
bnx2x-e1-7.2.51.0.fw   bnx2x-e1h-7.8.17.0.fw   bnx2x-e2-7.8.19.0.fw
bnx2x-e1-7.8.17.0.fw   bnx2x-e1h-7.8.19.0.fw   bnx2x-e2-7.8.2.0.fw

Reverting 5e091e7a "bnx2x: Utilize FW 7.13.1.0" avoids the problem.
I assume getting 7.13.1.0 from the linux-firmware project will also do =
so.

Could the driver fall back to an older firmware version more gracefully=
?

4.6rc7
=3D=3D=3D=3D=3D=3D
[=A0=A0=A0 0.000000] Linux version 4.6.0-rc7+ ... (gcc version 4.8.5 20=
150623 (Red Hat 4.8.5-4) (GCC) ) #7 SMP Mon May 9 14:22:53 EDT 2016
[=A0=A0=A0 0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-4.6.0-rc7+ roo=
t=3D/dev/mapper/rhel-root ro crashkernel=3Dauto rd.lvm.lv=3Drhel/root r=
d.lvm.lv=3Drhel/swap rhgb quiet efi=3Ddebug ... ignore_loglevel console=
=3DttyS1,115200 console=3Dtty0 LANG=3Den_US.UTF-8=20
=2E..
[=A0=A0 16.143816] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Dri=
ver bnx2x 1.712.30-0 (2014/02/10)
[=A0=A0 16.144780] bnx2x 0000:04:00.0: msix capability found
[=A0=A0 16.144995] bnx2x 0000:04:00.0: part number 0-0-0-0
[=A0=A0 16.237686] bnx2x 0000:04:00.1: msix capability found
[=A0=A0 16.237859] bnx2x 0000:04:00.1: part number 0-0-0-0
[=A0=A0 16.525718] bnx2x 0000:04:00.1 eno50: renamed from eth2
[=A0=A0 16.648816] bnx2x 0000:04:00.0 eno49: renamed from eth1
=2E..
[=A0=A0 47.333227] IPv6: ADDRCONF(NETDEV_UP): eno2: link is not ready
[=A0=A0 47.498841] IPv6: ADDRCONF(NETDEV_UP): eno2: link is not ready
[=A0=A0 47.530225] IPv6: ADDRCONF(NETDEV_UP): eno3: link is not ready
[=A0=A0 47.680716] IPv6: ADDRCONF(NETDEV_UP): eno3: link is not ready
[=A0=A0 47.714908] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
[=A0=A0 47.874737] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
[=A0=A0 47.907457] IPv6: ADDRCONF(NETDEV_UP): eno50: link is not ready
[=A0=A0 47.977221] bnx2x 0000:04:00.1: Direct firmware load for bnx2x/b=
nx2x-e2-7.13.1.0.fw failed with error -2
[=A0=A0 48.029997] bnx2x 0000:04:00.1: Falling back to user helper
[=A0=A0 51.104604] tg3 0000:02:00.1 eno2: Link is up at 1000 Mbps, full=
 duplex
[=A0=A0 51.142403] tg3 0000:02:00.1 eno2: Flow control is off for TX an=
d off for RX
[=A0=A0 51.180648] tg3 0000:02:00.1 eno2: EEE is disabled
[**=A0=A0=A0 ] A start job is running for Network Manager Wait Online (=
1min 27s / no limit)
[=A0 108.064132] bnx2x: [bnx2x_init_firmware:13472(eno50)]Can't load fi=
rmware file bnx2x/bnx2x-e2-7.13.1.0.fw
[=A0 108.119951] bnx2x: [bnx2x_func_hw_init:5785(eno50)]Error loading f=
irmware
[=A0 108.156522] bnx2x: [bnx2x_nic_load:2727(eno50)]HW init failed, abo=
rting
[*=A0=A0=A0=A0 ] A start job is running for Network Manager Wait Online=
 (1min 28s / no limit)
[=A0 108.435477] IPv6: ADDRCONF(NETDEV_CHANGE): eno2: link becomes read=
y
[=A0 108.475065] IPv6: ADDRCONF(NETDEV_UP): eno49: link is not ready
[=A0 108.556168] bnx2x 0000:04:00.0: Direct firmware load for bnx2x/bnx=
2x-e2-7.13.1.0.fw failed with error -2
[=A0 108.608229] bnx2x 0000:04:00.0: Falling back to user helper
[=A0 169.337933] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
[=A0 169.338749] IPv6: ADDRCONF(NETDEV_UP): eno50: link is not ready
[=A0 169.339772] IPv6: ADDRCONF(NETDEV_UP): eno49: link is not ready
[=A0 169.340630] IPv6: ADDRCONF(NETDEV_UP): eno4: link is not ready
=A0=A0=A0=A0=A0=A0=A0=A0 Starting WPA Supplicant daemon...
[=A0 OK=A0 ] Started WPA Supplicant daemon.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Network Manager Script Dispatcher Ser=
vice...
[=A0 OK=A0 ] Started Network Manager Script Dispatcher Service.
[=A0 OK=A0 ] Started Network Manager Wait Online.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting LSB: Bring up/down networking...
[FAILED] Failed to start LSB: Bring up/down networking.
See 'systemctl status network.service' for details.
[=A0 OK=A0 ] Reached target Network.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Logout off all iSCSI sessions on shut=
down...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Enable periodic update of entitlement=
 certificates....
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Dynamic System Tuning Daemon...
[=A0 OK=A0 ] Started CUPS Printing Service.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting CUPS Printing Service...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Notify NFS peers of a restart...
[=A0 OK=A0 ] Started OpenSSH server daemon.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting OpenSSH server daemon...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Postfix Mail Transport Agent...
[=A0 OK=A0 ] Reached target Network is Online.
[=A0 OK=A0 ] Started Logout off all iSCSI sessions on shutdown.
[=A0 OK=A0 ] Started Enable periodic update of entitlement certificates=
=2E.
[=A0 OK=A0 ] Started Notify NFS peers of a restart.
[=A0 OK=A0 ] Started Dynamic System Tuning Daemon.
[=A0 OK=A0 ] Reached target Remote File Systems (Pre).
[=A0 OK=A0 ] Reached target Remote File Systems.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Virtualization daemon...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Permit User Sessions...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting LSB: Starts the Spacewalk Daemon...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Crash recovery kernel arming...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Availability of block devices...
[=A0 OK=A0 ] Started Virtualization daemon.
[=A0 OK=A0 ] Started Permit User Sessions.
[=A0 OK=A0 ] Started LSB: Starts the Spacewalk Daemon.
[=A0 OK=A0 ] Started Availability of block devices.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Wait for Plymouth Boot Screen to Quit=
=2E..
[=A0 OK=A0 ] Started Command Scheduler.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Command Scheduler...
[=A0 OK=A0 ] Started Job spooling tools.
=A0=A0=A0=A0=A0=A0=A0=A0 Starting Job spooling tools...
=A0=A0=A0=A0=A0=A0=A0=A0 Starting GNOME Display Manager...
[ =A0176.171405] tun: Universal TUN/TAP device driver, 1.6
[=A0 176.171406] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[=A0 OK=A0 ] Started Postfix Mail Transport Agent.
[=A0 OK=A0 ] Started GNOME Display Manager.
[=A0 176.747016] virbr0: port 1(virbr0-nic) entered blocking state
[=A0 176.778078] virbr0: port 1(virbr0-nic) entered disabled state
[=A0 176.808991] device virbr0-nic entered promiscuous mode
[=A0 177.007764] virbr0: port 1(virbr0-nic) entered blocking state
[=A0 177.011281] virbr0: port 1(virbr0-nic) entered listening state
[=A0 177.046773] virbr0: port 1(virbr0-nic) entered disabled state

Red Hat Enterprise Linux Server 7.2 (Maipo)
Kernel 4.6.0-rc7+ on an x86_64

s71 login:


4.2
=3D=3D=3D=20
[    0.000000] Linux version 4.2.0-380.13.hpoj.x86_64 (root@blrh6u2x640=
05) (gcc version 4.8.3 20140911 (Red Hat 4.8.3-9) (GCC) ) #1 SMP Fri Ma=
r 4 13:19:33 CST 2016
[    0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-4.2.0-380.13.hpoj.x8=
6_64 root=3D/dev/mapper/rhel-root ro crashkernel=3Dauto rd.lvm.lv=3Drhe=
l/root rd.lvm.lv=3Drhel/swap rhgb quiet efi=3Ddebug ... ignore_loglevel=
 console=3DttyS1,115200 console=3Dtty0=20
=2E..
[   46.888499] IPv6: ADDRCONF(NETDEV_UP): eno2: link is not ready
[   46.889525] IPv6: ADDRCONF(NETDEV_UP): eno50: link is not ready
         Starting Network Manager Wait Online...
[   47.420000] bnx2x 0000:04:00.1 eno50: using MSI-X  IRQs: sp 108  fp[=
0] 110 ... fp[7] 117
[   48.118821] IPv6: ADDRCONF(NETDEV_UP): eno50: link is not ready
[   48.153042] IPv6: ADDRCONF(NETDEV_UP): eno3: link is not ready
[   48.324725] IPv6: ADDRCONF(NETDEV_UP): eno3: link is not ready
[   48.360099] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
[   48.530094] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
[   48.564963] IPv6: ADDRCONF(NETDEV_UP): eno49: link is not ready
[   49.112598] bnx2x 0000:04:00.0 eno49: using MSI-X  IRQs: sp 98  fp[0=
] 100 ... fp[7] 107
[   49.716845] IPv6: ADDRCONF(NETDEV_UP): eno49: link is not ready
[   49.752453] IPv6: ADDRCONF(NETDEV_UP): eno4: link is not ready
[   49.918571] IPv6: ADDRCONF(NETDEV_UP): eno4: link is not ready
[   49.957314] IPv6: ADDRCONF(NETDEV_UP): eno2: link is not ready
[   49.989835] IPv6: ADDRCONF(NETDEV_UP): eno50: link is not ready
[   50.022918] IPv6: ADDRCONF(NETDEV_UP): eno3: link is not ready
[   50.055375] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
[   50.087663] IPv6: ADDRCONF(NETDEV_UP): eno49: link is not ready
[   50.119932] IPv6: ADDRCONF(NETDEV_UP): eno4: link is not ready
         Starting WPA Supplicant daemon...
[  OK  ] Started WPA Supplicant daemon.
[   50.401735] tg3 0000:02:00.1 eno2: Link is up at 1000 Mbps, full dup=
lex
[   50.439124] tg3 0000:02:00.1 eno2: Flow control is off for TX and of=
f for RX
[   50.476727] tg3 0000:02:00.1 eno2: EEE is disabled
[   50.502943] IPv6: ADDRCONF(NETDEV_CHANGE): eno2: link becomes ready
[  OK  ] Started Network Manager Wait Online.
         Starting LSB: Bring up/down networking...
         Starting Network Manager Script Dispatcher Service...
[  OK  ] Started Network Manager Script Dispatcher Service.
[FAILED] Failed to start LSB: Bring up/down networking.
See 'systemctl status network.service' for details.
[  OK  ] Reached target Network.
         Starting Notify NFS peers of a restart...
[  OK  ] Reached target Network is Online.
         Starting Dynamic System Tuning Daemon...
         Starting Enable periodic update of entitlement certificates...=
=2E
[  OK  ] Started CUPS Printing Service.
         Starting CUPS Printing Service...
         Starting Logout off all iSCSI sessions on shutdown...
         Starting Postfix Mail Transport Agent...
[  OK  ] Started OpenSSH server daemon.
         Starting OpenSSH server daemon...
[  OK  ] Started Notify NFS peers of a restart.
[  OK  ] Started Enable periodic update of entitlement certificates..
[  OK  ] Started Logout off all iSCSI sessions on shutdown.
         Starting Availability of block devices...
[  OK  ] Reached target Remote File Systems (Pre).
[  OK  ] Reached target Remote File Systems.
         Starting Crash recovery kernel arming...
         Starting Virtualization daemon...
         Starting Permit User Sessions...
         Starting LSB: Starts the Spacewalk Daemon...
[  OK  ] Started Availability of block devices.
[  OK  ] Started Permit User Sessions.
[  OK  ] Started LSB: Starts the Spacewalk Daemon.
[  OK  ] Started Dynamic System Tuning Daemon.
         Starting GNOME Display Manager...
[  OK  ] Started Command Scheduler.
         Starting Command Scheduler...
[  OK  ] Started Job spooling tools.
         Starting Job spooling tools...
         Starting Wait for Plymouth Boot Screen to Quit...
[  OK  ] Started Virtualization daemon.
[  OK  ] Started GNOME Display Manager.
[   59.203229] tun: Universal TUN/TAP device driver, 1.6
[   59.232283] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   59.624817] virbr0: port 1(virbr0-nic) entered blocking state
[   59.656216] virbr0: port 1(virbr0-nic) entered disabled state
[   59.687578] device virbr0-nic entered promiscuous mode
[   59.879160] virbr0: port 1(virbr0-nic) entered blocking state
[   59.882383] virbr0: port 1(virbr0-nic) entered listening state
[   60.865748] bnx2x 0000:04:00.0 eno49: using MSI-X  IRQs: sp 98  fp[0=
] 100 ... fp[7] 107
[   61.891547] virbr0: port 1(virbr0-nic) entered learning state
[   62.217602] bnx2x 0000:04:00.1 eno50: using MSI-X  IRQs: sp 108  fp[=
0] 110 ... fp[7] 117
[   62.905227] virbr0: port 1(virbr0-nic) entered disabled state

Red Hat Enterprise Linux Server 7.2 (Maipo)
Kernel 4.6.0-rc7+ on an x86_64

s71 login:=20

---
Robert Elliott, HPE Persistent Memory
