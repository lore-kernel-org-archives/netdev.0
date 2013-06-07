From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [xfrm?] BUG: unable to handle kernel NULL pointer dereference at
 00000004
Date: Fri, 7 Jun 2013 15:32:15 +0800
Message-ID: <20130607073215.GA13065@localhost>
References: <20130606125549.GA17577@localhost>
 <20130607070243.GD3109@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fan Du <fan.du@windriver.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130607070243.GD3109@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 07, 2013 at 09:02:43AM +0200, Steffen Klassert wrote:
> On Thu, Jun 06, 2013 at 08:55:49PM +0800, Fengguang Wu wrote:
> > Greetings,
> > 
> > I got the below dmesg and the first bad commit is
> > 
> > commit 4c4d41f200db375b2d2cc6d0a1de0606c8266398
> > Author: Fan Du <fan.du@windriver.com>
> > Date:   Thu Jun 6 10:15:54 2013 +0800
> > 
> >     xfrm: add LINUX_MIB_XFRMACQUIREERROR statistic counter
> >     
> >     When host ping its peer, ICMP echo request packet triggers IPsec
> >     policy, then host negotiates SA secret with its peer. After IKE
> >     installed SA for OUT direction, but before SA for IN direction
> >     installed, host get ICMP echo reply from its peer. At the time
> >     being, the SA state for IN direction could be XFRM_STATE_ACQ,
> >     then the received packet will be dropped after adding
> >     LINUX_MIB_XFRMINSTATEINVALID statistic.
> >     
> >     Adding a LINUX_MIB_XFRMACQUIREERROR statistic counter for such
> >     scenario when SA in larval state is much clearer for user than
> >     LINUX_MIB_XFRMINSTATEINVALID which indicates the SA is totally
> >     bad.
> >     
> >     Signed-off-by: Fan Du <fan.du@windriver.com>
> >     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > 
> > 
> > [  157.721828] no cont in shutdown!
> > [  158.779481] floppy0: FDC access conflict!
> > [  159.555337] BUG: unable to handle kernel NULL pointer dereference at 00000004
> > [  160.102544] IP: [<c1609ed5>] reset_interrupt+0x85/0x90
> > [  160.102544] *pde = 00000000 
> > [  160.102544] Oops: 0000 [#1] PREEMPT SMP 
> > [  160.102544] CPU: 1 PID: 89 Comm: kworker/u4:1 Not tainted 3.10.0-rc2-00597-g4c4d41f #3
> > [  160.102544] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> > [  160.102544] Workqueue: floppy reset_interrupt
> > [  160.102544] task: c5a5ad00 ti: c5b5c000 task.ti: c5b5c000
> > [  160.102544] EIP: 0060:[<c1609ed5>] EFLAGS: 00010246 CPU: 1
> > [  160.102544] EIP is at reset_interrupt+0x85/0x90
> > [  160.102544] EAX: 00000000 EBX: cbd56600 ECX: c5a5ad00 EDX: 000003f4
> > [  160.102544] ESI: c1ed0e40 EDI: c5a23200 EBP: c5b5debc ESP: c5b5deac
> > [  160.102544]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> > [  160.102544] CR0: 8005003b CR2: 00000004 CR3: 02037000 CR4: 00000690
> > [  160.102544] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> > [  160.102544] DR6: ffff0ff0 DR7: 00000400
> > [  160.102544] Stack:
> > [  178.765341] pcd0: Autoprobe failed
> > [  178.765373] pcd: No CD-ROM drive found
> > 
> > Bisect log shows that
> > - reverting the commit fixes the problem
> > - linux-next is also impacted
> 
> Strange, your config has neither XFRM nor INET enabled. So the code in
> question should not be compiled into your kernel. Also your backtraces
> don't show any networking related functions.

That's interesting... I'll redo the bisect..

> Fan, can you look into this please?

Thanks,
Fengguang
