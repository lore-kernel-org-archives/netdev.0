From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 102181] New: kernel soft lockup when using
 tcp_keepalive_timer
Date: Sat, 1 Aug 2015 17:15:40 -0700
Message-ID: <20150801171540.2f6d8aa6@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33370 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700AbbHBAPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 20:15:31 -0400
Received: by padck2 with SMTP id ck2so62616358pad.0
        for <netdev@vger.kernel.org>; Sat, 01 Aug 2015 17:15:31 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id s7sm12754519pdn.85.2015.08.01.17.15.30
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Aug 2015 17:15:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 1 Aug 2015 09:43:46 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 102181] New: kernel soft lockup when using tcp_keepalive_timer


https://bugzilla.kernel.org/show_bug.cgi?id=102181

            Bug ID: 102181
           Summary: kernel soft lockup when using tcp_keepalive_timer
           Product: Networking
           Version: 2.5
    Kernel Version: 3.0.93
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: 13806511171@163.com
        Regression: No

Kernel report soft lockup when call the timer function tcp_keepalive_timer.
Only one cpu dead lock in bh_lock_sock(sk);
And all the other CPUs are idle.
The kernel version is 3.0.93.
And the messages:

[73136.797013] BUG: soft lockup - CPU#3 stuck for 22s! [neutron-server:5728]
[73136.804090] Modules linked in: ip6table_filter ip6table_raw ip6_tables
iptable_raw iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi xt_tcpudp
iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 edd joydev
st sr_mod ide_gd_mod(N) ide_cd_mod ide_core cdrom xfs 8021q garp stp llc
sch_htb af_packet softdog signo_catch(N) ipmi_devintf ipmi_si ipmi_msghandler
kbox(F) iptable_filter ip_tables x_tables openvswitch nf_conntrack crc32c
libcrc32c gre mperf uio nbd bonding vhost_scsi target_core_mod configfs ext4(N)
jbd2 crc16 loop vhost_net macvtap macvlan tun kvm_intel kvm ipv6 ipv6_lib ahci
libahci libata i2c_i801 ixgbe(X) pcspkr hio(FN) i2c_core ses dca enclosure sg
rtc_cmos acpi_power_meter button container ext3 jbd mbcache dm_mirror
dm_region_hash dm_log linear sd_mod crc_t10dif ehci_hcd usbcore mpt3sas
usb_common scsi_transport_sas raid_class processor thermal_sys hwmon
scsi_dh_emc scsi_dh_alua scsi_dh_rdac scsi_dh_hp_sw scsi_dh scsi_mod
dm_snapshot dm_mod [last unloaded: iTCO_vendor_support]
[73136.899222] Supported: No, Unsupported modules are loaded
[73136.904927] CPU 3 
[73136.906762] Modules linked in: ip6table_filter ip6table_raw ip6_tables
iptable_raw iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi xt_tcpudp
iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 edd joydev
st sr_mod ide_gd_mod(N) ide_cd_mod ide_core cdrom xfs 8021q garp stp llc
sch_htb af_packet softdog signo_catch(N) ipmi_devintf ipmi_si ipmi_msghandler
kbox(F) iptable_filter ip_tables x_tables openvswitch nf_conntrack crc32c
libcrc32c gre mperf uio nbd bonding vhost_scsi target_core_mod configfs ext4(N)
jbd2 crc16 loop vhost_net macvtap macvlan tun kvm_intel kvm ipv6 ipv6_lib ahci
libahci libata i2c_i801 ixgbe(X) pcspkr hio(FN) i2c_core ses dca enclosure sg
rtc_cmos acpi_power_meter button container ext3 jbd mbcache dm_mirror
dm_region_hash dm_log linear sd_mod crc_t10dif ehci_hcd usbcore mpt3sas
usb_common scsi_transport_sas raid_class processor thermal_sys hwmon
scsi_dh_emc scsi_dh_alua scsi_dh_rdac scsi_dh_hp_sw scsi_dh scsi_mod
dm_snapshot dm_mod [last unloaded: iTCO_vendor_support]
[73137.009680] Supported: No, Unsupported modules are loaded
[73137.015376] 
[73137.017177] Pid: 5728, comm: neutron-server Tainted: GF       W  NX
3.0.93-0.8-default #1 To be filled by O.E.M. RH2288H V3/BC11HGSA0
[73137.029814] RIP: 0010:[<ffffffff81460158>]  [<ffffffff81460158>]
_raw_spin_lock+0x18/0x20
[73137.038619] RSP: 0000:ffff88307fc63e28  EFLAGS: 00000297
[73137.044212] RAX: 0000000000000001 RBX: ffff882f5d7e87d0 RCX:
ffff882f5f288020
[73137.051642] RDX: 0000000000000000 RSI: ffffffff813f40d0 RDI:
ffff882d351e2850
[73137.059020] RBP: ffff882d351e29b0 R08: dead000000200200 R09:
ffff8828a33fa348
[73137.066441] R10: 00000000000007c7 R11: ffffffff81025b00 R12:
ffffffff81468a73
[73137.073823] R13: ffff88307fc63d98 R14: ffff882d351e2800 R15:
ffff882d351e2800
[73137.081255] FS:  00002b3127ea2b20(0000) GS:ffff88307fc60000(0000)
knlGS:0000000000000000
[73137.089952] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[73137.095996] CR2: 00002b8ab967fb90 CR3: 00000028a3674000 CR4:
00000000001407e0
[73137.103372] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[73137.110811] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[73137.118241] Process neutron-server (pid: 5728, threadinfo ffff8828a368a000,
task ffff8828a33fa300)
[73137.127806] Stack:
[73137.130133]  ffffffff813f40f1 ffff882d351e29b0 ffff882d351e29b0
0000000000000100
[73137.138221]  ffffffff8106f45b ffff882d351e29b0 ffff882f5f288000
0000000000000008
[73137.146199]  ffff88307fc63ea0 ffffffff813f40d0 ffffffff81070873
ffff882f5f289c20
[73137.154287] Call Trace:
[73137.157049]  [<ffffffff813f40f1>] tcp_keepalive_timer+0x21/0x270
[73137.163364]  [<ffffffff8106f45b>] call_timer_fn+0x6b/0x120
[73137.169148]  [<ffffffff81070873>] run_timer_softirq+0x173/0x240
[73137.175315]  [<ffffffff8106769f>] __do_softirq+0xef/0x220
[73137.181014]  [<ffffffff814692dc>] call_softirq+0x1c/0x30
[73137.186631]  [<ffffffff810044d5>] do_softirq+0x65/0xa0
[73137.192078]  [<ffffffff81067495>] irq_exit+0xc5/0xe0
[73137.197349]  [<ffffffff810268f8>] smp_apic_timer_interrupt+0x68/0xa0
[73137.203956]  [<ffffffff81468a73>] apic_timer_interrupt+0x13/0x20
[73137.210261]  [<00002b3126f9dee5>] 0x2b3126f9dee4

-- 
You are receiving this mail because:
You are the assignee for the bug.
