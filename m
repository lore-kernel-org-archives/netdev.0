From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH RFC 00/73] tree-wide: clean up some no longer required
 #include <linux/init.h>
Date: Wed, 22 Jan 2014 19:38:39 -0500
Message-ID: <20140123003838.GA10182@windriver.com>
References: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
 <20140122180023.dd90d34cba38d9f9ac516349@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <linux-arch@vger.kernel.org>,
        <linux-alpha@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-ia64@vger.kernel.org>, <linux-m68k@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <linuxppc-dev@lists.ozlabs.org>,
        <linux-s390@vger.kernel.org>, <sparclinux@vger.kernel.org>,
        <x86@kernel.org>, <netdev@vger.kernel.org>, <kvm@vger.kernel.org>,
        <rusty@rustcorp.com.au>, <gregkh@linuxfoundation.org>,
        <akpm@linux-foundation.org>, <torvalds@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20140122180023.dd90d34cba38d9f9ac516349@canb.auug.org.au>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

[Re: [PATCH RFC 00/73] tree-wide: clean up some no longer required #include <linux/init.h>] On 22/01/2014 (Wed 18:00) Stephen Rothwell wrote:

> Hi Paul,
> 
> On Tue, 21 Jan 2014 16:22:03 -0500 Paul Gortmaker <paul.gortmaker@windriver.com> wrote:
> >
> > Where: This work exists as a queue of patches that I apply to
> > linux-next; since the changes are fixing some things that currently
> > can only be found there.  The patch series can be found at:
> > 
> >    http://git.kernel.org/cgit/linux/kernel/git/paulg/init.git
> >    git://git.kernel.org/pub/scm/linux/kernel/git/paulg/init.git
> > 
> > I've avoided annoying Stephen with another queue of patches for
> > linux-next while the development content was in flux, but now that
> > the merge window has opened, and new additions are fewer, perhaps he
> > wouldn't mind tacking it on the end...  Stephen?
> 
> OK, I have added this to the end of linux-next today - we will see how we
> go.  It is called "init".

Thanks, it was a great help as it uncovered a few issues in fringe arch
that I didn't have toolchains for, and I've fixed all of those up.

I've noticed that powerpc has been un-buildable for a while now; I have
used this hack patch locally so I could run the ppc defconfigs to check
that I didn't break anything.  Maybe useful for linux-next in the
interim?  It is a hack patch -- Not-Signed-off-by: Paul Gortmaker.  :)

Paul.
--

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index d27960c89a71..d0f070a2b395 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -560,9 +560,9 @@ extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
 
 #define pmd_move_must_withdraw pmd_move_must_withdraw
-typedef struct spinlock spinlock_t;
-static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
-					 spinlock_t *old_pmd_ptl)
+struct spinlock;
+static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
+					 struct spinlock *old_pmd_ptl)
 {
 	/*
 	 * Archs like ppc64 use pgtable to store per pmd
