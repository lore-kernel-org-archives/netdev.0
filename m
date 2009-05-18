From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.30-rc6: Reported regressions from 2.6.29
Date: Mon, 18 May 2009 08:32:18 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0905180819130.3301@localhost.localdomain>
References: <_AjETDMbIoL.A.DcH.RYzDKB@chimera> <20090517073327.GC1583@elte.hu>
	<20090518145725.GB18607@redhat.com> <20090518151102.GA6241@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Kumar Gala <galak@kernel.crashing.org>,
        Natalie Protasevich <protasnb@gmail.com>, Martin Bammer <mrb74@gmx.at>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Jeff Garzik <jgarzik@pobox.com>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <20090518151102.GA6241@elte.hu>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Mon, 18 May 2009, Ingo Molnar wrote:
> 
> Btw., why did the patch (and the revert) make any difference to the 
> test? Timing differences look improbable.

It's the change from

	!signal_group_exit(signal)

to

	!sig_kernel_only(signr)

and quite frankly, I still don't see the point.

The comment seems to be wrong too:

    If SIGSTOP/SIGKILL originate from a descendant of container-init they are
    never queued (i.e dropped in sig_ignored() in an earler patch).
    
    If SIGSTOP/SIGKILL originate from parent namespace, the signal is queued
    and container-init processes the signal.

since the bug was that the SIGSTOP (from within the same container) was 
_not_ ignored like the comment says.

			Linus
