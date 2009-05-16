From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG 2.6.30-rc1] panic when loading oprofile
Date: Sat, 16 May 2009 16:20:17 -0700
Message-ID: <20090516162017.2525511c.akpm@linux-foundation.org>
References: <alpine.WNT.2.00.0905131327430.7052__41366.1100705669$1242253861$gmane$org@jbrandeb-desk1.amr.corp.intel.com>
	<87fxf6pmh5.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <oprofile-list-bounces@lists.sourceforge.net>
In-Reply-To: <87fxf6pmh5.fsf@basil.nowhere.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=oprofile-list>
List-Post: <mailto:oprofile-list@lists.sourceforge.net>
List-Help: <mailto:oprofile-list-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=subscribe>
Errors-To: oprofile-list-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 15 May 2009 14:41:26 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> "Brandeburg, Jesse" <jesse.brandeburg@intel.com> writes:
> 
> Hi Jesse,
> 
> > when starting a profile run on the latest net-next kernel, I'm currently 
> > trying to reproduce on 2.6.30-rc5 stock.
> 
> Were you able to reproduce it?
> 
> >
> > config available upon request, arch=x86_64, recent (F10 or newer) oprofile 
> > userspace.
> 
> it looks like two bugs: oprofile didn't catch a NMI that belongs to 
> it (most likely) and the NMI watchdog referenced a NULL pointer
> while processing an NMI.
> 
> Did you have the nmi watchdog enabled on the command line?
> 
> >
> > BUG: unable to handle kernel NULL pointer dereference at (null)
> > IP: [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
> 
> I don't get the same code as you. But the oopsing instruction in your
> oops is
> 
>   2b:*  44 0f a3 28             bt     %r13d,(%rax)     <-- trapping instruction
> 
> with rax == 0 and I suspect it's one of the new cpu mask checks
> I would try reverting
> 
> fcc5c4a2feea3886dc058498b28508b2731720d5
> 2f537a9f8e82f55c241b002c8cfbf34303b45ada
> fcef8576d8a64fc603e719c97d423f9f6d4e0e8b
> 
> and see which one causes it. That would only fix the NMI watchdog bug
> of course.
> 
> The oprofile not catching a event problem would be still open then.
> I think the checks for overflowed counters are not 100% perfect
> so that could happen. I have some patches in the works to use the new
> global status register on arch perfmon 2, with that the overflow
> check is somewhat more reliable. But that's more work.
> 

Ping?

This is in Rafael's regression list but I suspect that it's a
linux-next-only thing?


------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables 
unlimited royalty-free distribution of the report engine 
for externally facing server and web deployment. 
http://p.sf.net/sfu/businessobjects
