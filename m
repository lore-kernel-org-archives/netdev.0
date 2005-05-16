From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr
 (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Mon, 16 May 2005 02:59:01 -0700
Message-ID: <20050516025901.4b26ccf3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hejianj@cn.ibm.com, linuxppc64-dev@lists.linuxppc.org.sgi.com,
        Anton Blanchard
 <anton@samba.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Might be a bug in the e100 driver, might not be.

I assume this is the

	BUG_ON(skb->list != NULL);

in __kfree_skb(), although the line number is off-by-one, and the
.__kfree_skb+0x188/0x240 would tend to contradict that.  Anton, can you
help work out where we went splat please?

tx timeouts are fairly rare events, so this might not be a recently-added
bug.

Do we know if it is repeatable?



Begin forwarded message:

Date: Mon, 16 May 2005 02:44:04 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4


http://bugme.osdl.org/show_bug.cgi?id=4628

           Summary: Test server hang while running rhr (network) test on
                    RHEL4 with kernel 2.6.12-rc1-mm4
    Kernel Version: 2.6.12-rc1 with mm4 patch
            Status: NEW
          Severity: normal
             Owner: anton@samba.org
         Submitter: hejianj@cn.ibm.com
                CC: hanwenb@cn.ibm.com,mridge@us.ibm.com,rende@cn.ibm.com,wa
                    ngjs@cn.ibm.com


Distribution:
RHEL4 with kernel 2.6.12-rc1-mm4

Hardware Environment:
IBM OpenPower( CHRP IBM,9124-720 )

Software Environment:
RHEL4
RHR: rhr2-rhel4-1.0-14a.noarch.rpm

Problem Description:
The test server hang while running rhr (network) test on RHEL4 with kernel 
2.6.12-rc1-mm4.

Steps to reproduce:
1. Download kernel 2.6.12-rc1 and 2.6.12-rc1-mm4 patch from kernel.org, then 
build the kernel on OpenPower 720
2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.com and install it on 
the test machine.
3. Configure and run the rhr test via invoking redhat-ready.

Additional information:
Here is the backtrace from xmon.

3:mon> e
cpu 0x3: Vector: 700 (Program Check) at [c00000000ffe7920]
    pc: c00000000029632c: .__kfree_skb+0x188/0x240
    lr: c000000000296328: .__kfree_skb+0x184/0x240
    sp: c00000000ffe7ba0
   msr: 8000000000029032
  current = 0xc000000107f94040
  paca    = 0xc000000000431c00
    pid   = 0, comm = swapper
kernel BUG in __kfree_skb at net/core/skbuff.c:282!

3:mon> t
[c00000000ffe7c40] d0000000000ebac4 .e100_rx_clean_list+0xa0/0x144 [e100]
[c00000000ffe7ce0] d0000000000ed6dc .e100_tx_timeout+0x7c/0xb0 [e100]
[c00000000ffe7d70] c0000000002b87bc .dev_watchdog+0xc8/0x154
[c00000000ffe7e00] c00000000006d6b4 .run_timer_softirq+0x180/0x298
[c00000000ffe7ed0] c0000000000667d8 .__do_softirq+0xdc/0x1b8
[c00000000ffe7f90] c000000000014bf0 .call_do_softirq+0x14/0x24
[c000000086b43860] c0000000000102c4 .do_softirq+0x98/0xac
[c000000086b438f0] c0000000000669cc .irq_exit+0x70/0x8c
[c000000086b43970] c000000000011fb8 .timer_interrupt+0x398/0x47c
[c000000086b43a90] c00000000000a2b4 decrementer_common+0xb4/0x100
--- Exception: 901 (Decrementer) at c000000000010554 .dedicated_idle+0x114/0x280
[c000000086b43e80] c0000000000108c8 .cpu_idle+0x3c/0x54
[c000000086b43f00] c00000000003cc8c .start_secondary+0x108/0x148
[c000000086b43f90] c00000000000bd84 .enable_64b_mode+0x0/0x28

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
