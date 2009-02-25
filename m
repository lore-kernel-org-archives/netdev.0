From: Rini van Zetten <rini@arvoo.nl>
Subject: gianfar device hangs when transmitting tcp frames
Date: Wed, 25 Feb 2009 16:02:39 +0100
Message-ID: <49A55D8F.20509@arvoo.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: afleming@freescale.com, Linuxppc-dev@ozlabs.org,
 netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi,

We have a home made board with the mpc8377E.
We use the latest linux kernel 2.6.29-rc6.

The problem occurs when send a lot of tcp packet (eg by iperf as client)
sometimes we get an watchdog timeout : see below.

If we undo the commit  :

-#define BD_LENGTH_MASK         0x00ff
+#define BD_LENGTH_MASK         0x0000ffff

the device works fine.

Is this commit introducing a bug or is it another problem ?

Regards,
Rini



kernel: NETDEV WATCHDOG: eth0 (fsl-gianfar): transmit timed out
kernel: ------------[ cut here ]------------
kernel: Badness at /arv-002/rini/Projects/ax601/linux-galak/net/sched/sch_generic.c:226
kernel: NIP: c02f6920 LR: c02f6920 CTR: 00000001
kernel: REGS: c04cbd00 TRAP: 0700   Not tainted  (2.6.29-rc5-arvoo-0.2)
kernel: MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002024  XER: 20000000
kernel: TASK = c04a0588[0] 'swapper' THREAD: c04ca000
kernel: GPR00: c02f6920 c04cbdb0 c04a0588 0000003b 000027aa ffffffff c04d0000 00020000
kernel: GPR08: 00000036 00000000 000027aa c04a2414 44002082 00000000 07ffc000 06fb1000
kernel: GPR16: 01000100 00000000 00000000 00000000 03000130 07daf863 00000001 c04f0000
kernel: GPR24: c0410000 00000000 c78431c0 c04ca000 c7843000 00000001 c04d0000 c04a0000
kernel: NIP [c02f6920] dev_watchdog+0x2e8/0x2f8
kernel: LR [c02f6920] dev_watchdog+0x2e8/0x2f8
kernel: Call Trace:
kernel: [c04cbdb0] [c02f6920] dev_watchdog+0x2e8/0x2f8 (unreliable)
kernel: [c04cbe20] [c002b314] run_timer_softirq+0x180/0x224
kernel: [c04cbe50] [c0025b0c] __do_softirq+0x84/0x128
kernel: [c04cbe80] [c00060f8] do_softirq+0x58/0x5c
kernel: [c04cbe90] [c0025730] irq_exit+0x60/0x80
kernel: [c04cbea0] [c000e94c] timer_interrupt+0x12c/0x188
kernel: [c04cbec0] [c0012130] ret_from_except+0x0/0x14
kernel: --- Exception: 901 at cpu_idle+0xa0/0x100
kernel:     LR = cpu_idle+0xa0/0x100
kernel: [c04cbf80] [c00094dc] cpu_idle+0xe4/0x100 (unreliable)
kernel: [c04cbfa0] [c036af70] __got2_end+0x7c/0x90
kernel: [c04cbfc0] [c04747e0] start_kernel+0x224/0x2a8
kernel: [c04cbff0] [00003438] 0x3438
kernel: Instruction dump:
kernel: 38000001 7c0903a6 4bfffe28 38810008 7f83e378 38a00040 4bfeb539 7f84e378
kernel: 7c651b78 3c60c045 38638c24 4bd29cc1 <0fe00000> 38000001 901e1b24 4bffff94
