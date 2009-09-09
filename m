From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Next Sept 7: Bug : skb_release_head_state on x86
Date: Wed, 09 Sep 2009 14:10:32 +0200
Message-ID: <4AA79B38.6080005@gmail.com>
References: <20090907210206.7830ba68.sfr@canb.auug.org.au> <4AA5399A.405@in.ibm.com> <4AA5400E.9010108@gmail.com> <4AA5E717.1050002@in.ibm.com> <4AA78DD4.60003@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, David Miller <davem@davemloft.net>
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4AA78DD4.60003@in.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sachin Sant a =E9crit :
> Sachin Sant wrote:
>> Will try to boot 0904 and will check if the same problem can be
>> recreated.
> I still have this problem with next-20090908.Although the trace
> looks a bit different.
>=20
> Haven't checked today's next.
>=20
> BUG: unable to handle kernel paging request at 00008c90
> IP: [<c0349399>] skb_dma_unmap+0x15/0x91
> *pdpt =3D 0000000035445001 *pde =3D 0000000000000000
> Oops: 0000 [#2] SMP
> last sysfs file: /sys/devices/system/cpu/cpu3/topology/core_siblings
> Modules linked in: ipv6 microcode fuse loop dm_mod i2c_piix4 tg3
> i2c_core pcspkr ppdev button libphy sworks_agp rtc_cmos rtc_core
> parport_pc sr_mod rtc_lib sg parport agpgart cdrom floppy ohci_hcd
> ehci_hcd sd_mod crc_t10dif usbcore edd fan ide_pci_generic serverwork=
s
> ide_core ata_generic pata_serverworks libata ips scsi_mod thermal
> processor thermal_sys hwmon [last unloaded: speedstep_lib]
>=20
> Pid: 6, comm: ksoftirqd/1 Tainted: G      D  =20
> (2.6.31-rc9-autotest-next-20090908-5-pae #1) eserver xSeries 235
> -[86717AX]-
> EIP: 0060:[<c0349399>] EFLAGS: 00010296 CPU: 1
> EIP is at skb_dma_unmap+0x15/0x91
> EAX: f5d3dc5c EBX: c056bba0 ECX: 00000001 EDX: 00008be8
> ESI: f4d3b2f0 EDI: 00008be8 EBP: f5c69ec4 ESP: f5c69eac
> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process ksoftirqd/1 (pid: 6, ti=3Df5c68000 task=3Df5c4f280 task.ti=3D=
f5c68000)
> Stack:
> 00000001 f5d3dc5c f5c69ec4 0000005f f4d3b2f0 00008be8 f5c69f3c f8d191=
a1
> <0> c148347c 00000040 f4900380 f4900340 00000000 f55b2000 f4900340 00=
000064
> <0> f553aa00 00000000 f4900340 00000000 f49006b8 d0622200 0000059a f4=
d377c0
> Call Trace:
> [<f8d191a1>] ? tg3_poll+0x10f/0x802 [tg3]
> [<c034c151>] ? net_rx_action+0x93/0x173
> [<c01376b8>] ? __do_softirq+0xa7/0x144
> [<c013777b>] ? do_softirq+0x26/0x2b
> [<c01377ca>] ? ksoftirqd+0x4a/0xae
> [<c0137780>] ? ksoftirqd+0x0/0xae
> [<c0146a56>] ? kthread+0x61/0x66
> [<c01469f5>] ? kthread+0x0/0x66
> [<c0103507>] ? kernel_thread_helper+0x7/0x10
> Code: 5a c0 74 07 89 d8 e8 f3 7b e6 ff ba f4 ff ff ff 89 d0 5b 5e 5d =
c3
> 55 89 e5 57 56 53 83 ec 0c 8b 1d c0 07 61 c0 89 4d e8 89 45 ec <8b> b=
a
> a8 00 00 00 83 7d e8 02 8b 42 50 8b 72 54 8b 4f 0c 8b 57
> EIP: [<c0349399>] skb_dma_unmap+0x15/0x91 SS:ESP 0068:f5c69eac
> CR2: 0000000000008c90
> ---[ end trace 9239788a6557ba57 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Pid: 6, comm: ksoftirqd/1 Tainted: G      D  =20
> 2.6.31-rc9-autotest-next-20090908-5-pae #1
>=20
> I went back and tried out some old next versions. Seems like
> the problem was introduced in next-20090903. next-20090902
> worked fine.
>=20
> Thanks
> -Sachin
>=20

There were some changes on net-next-2.6 for tg3, you could try to rever=
t them...

(They are working just fine on my machine, but I suspect you have a dif=
ferent chip)
# lspci | grep Ether
14:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gi=
gabit Ethernet (rev a3)
14:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gi=
gabit Ethernet (rev a3)



commit 7ab0f2736bfe137a82a7084bbfb5f809da95cabd
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Thu Sep 3 10:39:43 2009 +0000

    netdev: Remove redundant checks for CAP_NET_ADMIN in MDIO implement=
ations

    dev_ioctl() already checks capable(CAP_NET_ADMIN) before calling th=
e
    driver's implementation of MDIO ioctls.

    Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit daf09de817353f18bb81a23a023d429cfd258e62
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:22:42 2009 +0000

    tg3: Update version to 3.102

    This patch updates the tg3 version to 3.102.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 882e9793faa9425dff581c33b1af45ed10145626
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:21:36 2009 +0000

    tg3: Add MDIO bus address assignments

    The 5717 is a dual port chip that has a shared MDIO bus design.  Wh=
ile
    it is impossible for one function to interface with the wrong phy, =
that
    function still needs to know which MDIO bus address to use when
    interfacing with its own phy.  This patch adds code to determine wh=
ich
    MDIO bus address to use.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit a1b950d56de3c72bea3343f54de24c43fb7dc74e
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:20:17 2009 +0000

    tg3: Add 5717 NVRAM detection routines

    This patch adds NVRAM detection routines for the 5717.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit f6eb9b1fc1411d22c073f5264e5630a541d0f7df
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:19:53 2009 +0000

    tg3: Add 5717 asic rev

    This patch adds the 5717 asic rev.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 8d9d7cfc0ec2fe37ff9afd74326d03f38f96ad1b
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:19:05 2009 +0000

    tg3: Assign rx ret producer indexes by vector

    When RSS is enabled, the status block format changes slightly.  The
    "rx_jumbo_consumer", "reserved", and "rx_mini_consumer" members get
    mapped to the other three rx return ring producer indexes.  This pa=
tch
    introduces a new per-interrupt member which identifies which locati=
on
    in the status block a particular vector should look for return ring
    updates.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 0c1d0e2b05e92ad847b3ebe1c75b7974086bc8fa
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:16:33 2009 +0000

    tg3: Adjust RSS ring allocation strategies

    When multivector RSS is enabled, the first interrupt vector is only=
 used
    to report link interrupts and error conditions.  This patch changes=
 the
    code so that rx and tx ring resources are not allocated for this ve=
ctor.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit baf8a94a572928710e9e60967d153a7bf3aebd9c
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:13:00 2009 +0000

    tg3: Add RSS support

    This patch adds code needed to enable RSS.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit b6080e126012047d42e53154189fdca286d0600e
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:12:00 2009 +0000

    tg3: Add coalesce parameters for msix vectors

    This patch adds code to tune the coalescing parameters for the othe=
r
    msix vectors.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
commit fed9781081aa9600765346c108ff22751e003715
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:10:19 2009 +0000

    tg3: Enable NAPI instances for other int vectors

    This patch adds code to enable and disable the rest of the NAPI
    instances.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit fe5f5787f0866e9f883bdd90018a354f2f3defd1
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:09:39 2009 +0000

    tg3: Add TSS support

    This patch exposes the additional transmit rings to the kernel and =
makes
    the necessary modifications to transmit, open, and close paths.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
commit 89aeb3bceaa1a02651206a76a7b9dcb8f3884702
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:08:58 2009 +0000

    tg3: Update intmbox and coal_now for msix

    This patch fixes up two spots that need attention now that msix sup=
port
    has been added.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit f77a6a8e6cee17b21a43bdf6b853cc2fc0e2c4df
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:04:37 2009 +0000

    tg3: Add tx and rx ring resource tracking

    This patch adds code to assign status block, tx producer ring and r=
x
    return ring resources needed for the other interrupt vectors.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 646c9eddcffd202bb0f3d906cecf94eaf10cad31
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 12:58:41 2009 +0000

    tg3: Add mailbox assignments

    The 5717 assigns mailbox locations to interrupt vectors in a rather
    non-intuitive way.  (Much of the complexity stems from legacy
    compatibility issues.)  This patch implements the assignment scheme=
=2E

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 679563f47cd2547a0e091b5bd3ddf30027af6b08
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 12:55:46 2009 +0000

    tg3: Add MSI-X support

    This patch adds MSI-X support.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 4f125f42dd55390016e21f8b3960f99d02d1001f
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 12:55:02 2009 +0000

    tg3: Add support code around kernel interrupt API

    This patch adds code to support multiple interrupt vectors around t=
he
    kernel's interrupt API.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
commit 2d31ecaf10c4ae03d49aed516481b2839b0220f6
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 12:53:31 2009 +0000

    tg3: Create tg3_rings_reset()

    This patch moves most of the chip ring setup logic into a separate
    function.  This will make it easier to verify the multi ring setup
    changes.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit fd2ce37f8e4a570ce90b141a2e7c476c5b399836
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 12:51:13 2009 +0000

    tg3: Add per-int coalesce now member

    Each interrupt vector has its own bit in the host coalescing regist=
er to
    force that vector's status block to be updated and generate an
    interrupt.  This patch adds a member to the per-interrupt structure
    that records which bit belongs to that vector.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
commit f19af9c2cc015e42dfe4bd5c383e32066ec2801c
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 12:47:49 2009 +0000

    tg3: inline tg3_cond_int()

    This patch inlines the code of tg3_cond_int() into the function's o=
nly
    callsite.  This prep work makes the following patch cleaner.

    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
