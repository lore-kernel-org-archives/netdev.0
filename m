From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Wed, 30 Apr 2008 17:34:26 +0800
Message-ID: <1209548066.2827.42.camel@debian.sh.intel.com>
References: <87zlrgl09s.fsf@sparse.dyndns.org>
	 <1209435597.2624.35.camel@debian.sh.intel.com>
	 <20080429132720.GB4887@tuxdriver.com>
	 <1209521679.2827.23.camel@debian.sh.intel.com>
	 <Pine.LNX.4.64.0804291934470.18219@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jason Riedy <jason@acm.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Randy.Dunlap" <rdunlap@xenotime.net>,
	Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52604 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756644AbYD3JfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 05:35:25 -0400
In-Reply-To: <Pine.LNX.4.64.0804291934470.18219@shark.he.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-29 at 19:36 -0700, Randy.Dunlap wrote:
> On Wed, 30 Apr 2008, Zhu Yi wrote:
> 
> > On Tue, 2008-04-29 at 09:27 -0400, John W. Linville wrote:
> > > 
> > > > Do we have a way to make "select IWLWIFI" generate CONFIG_IWLWIFI
> > > with
> > > > the same state as CONFIG_IWLCORE (or CONFIG_IWL3945)? AFAICS,
> > > > CONFIG_IWLWIFI is always 'y' whenever CONFIG_IWLCORE is 'y' or 'm'.
> > > If
> > > > the latter is 'm', the Makefile will generate a empty built-in.o
> > > which
> > > > requires vmlinux to update unnecessarily every time we only compile
> > > > iwl3945/4965 modules.
> > > 
> > > Can you do something like  "default IWLCORE'?  Untested, off the top
> > > of my head...
> > 
> > I just realized the kernel now updates vmlinux when I type 'make' even
> > if nothing is changed in the source code. Is this a bug or feature?
> 
> I see files in arch/x86/kernel/acpi/realmode/ always being built.
> Is that what you see or is it something else?
> 
> You can do
>   make V=2 all >build.log 2>&1
> to see what is being rebuilt and hopefully why.
> Then post that and maybe we can fix it (with the right people helping).

I found below fixes the problem. Sam, could you take a look?

Thanks,
-yi


diff --git a/Makefile b/Makefile
index 39516bf..7788c77 100644
--- a/Makefile
+++ b/Makefile
@@ -812,7 +812,7 @@ endif
 
 # build vmlinux.o first to catch section mismatch errors early
 ifdef CONFIG_KALLSYMS
-.tmp_vmlinux1: vmlinux.o
+#.tmp_vmlinux1: vmlinux.o
 endif
 vmlinux.o: $(vmlinux-lds) $(vmlinux-init) $(vmlinux-main) FORCE
        $(call if_changed_rule,vmlinux-modpost)


