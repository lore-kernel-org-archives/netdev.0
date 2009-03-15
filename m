From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12876] New: irq 18: nobody cared
 after down-ing an e1000 interface
Date: Sun, 15 Mar 2009 14:30:58 -0700
Message-ID: <20090315143058.726ad8e9.akpm@linux-foundation.org>
References: <bug-12876-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lkundrak@v3.sk, bugme-daemon@bugzilla.kernel.org
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-12876-10286@http.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 15 Mar 2009 06:40:54 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12876
> 
>            Summary: irq 18: nobody cared after down-ing an e1000 interface
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.29-0.237.rc7.git4.fc11.i586
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: lkundrak@v3.sk
> 
> 
> Distribution: Fedora
> Hardware Environment:
> http://smolts.org/show?uuid=pub_63f33868-db84-4452-bb6d-eeb440ee5449
> 
> Problem Description:
> 
> I get the following OOPS when I down the e1000 network interface:
> 
> irq 18: nobody cared (try booting with the "irqpoll" option)
> Pid: 9014, comm: udevd Tainted: G        W  2.6.29-0.237.rc7.git4.fc11.i586 #1
> Call Trace:
>  [<c0471f2b>] __report_bad_irq+0x33/0x74
>  [<c047205e>] note_interrupt+0xf2/0x150
>  [<c04711e0>] ? handle_IRQ_event+0x4f/0x58
>  [<c04725e8>] handle_fasteoi_irq+0x94/0xb7
>  [<c0472554>] ? handle_fasteoi_irq+0x0/0xb7
>  <IRQ>  [<c04045ac>] ? common_interrupt+0x2c/0x40
> handlers:
> [<c05f3cb6>] (ata_sff_interrupt+0x0/0xb1)
> [<c06079ec>] (usb_hcd_irq+0x0/0xa3)
> Disabling IRQ #18
> 
> As you can see, the IRQ 18 is shared with ata_sff and usb_hcd.
> 
> I've tried to comment out e1000_free_irq() call from e1000_close() and added a
> printk() to e1000_intr(). After that, the problem didn't occur, but I've not
> seen the output of the printk in e1000_intr() (It was visible while the
> interface was up), as if it weren't called. Seems like the way shared
> interrupts work is beyond my understanding.
> 


------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
