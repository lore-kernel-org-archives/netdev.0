From: Anton Blanchard <anton@samba.org>
Subject: Re: select(0, ..) is valid ?
Date: Wed, 16 May 2007 10:37:03 -0500
Message-ID: <20070516153703.GA26912@kryten>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com> <20070515104453.f901e91f.akpm@linux-foundation.org> <Pine.LNX.4.64.0705151109021.31972@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0705151927360.28895@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Badari Pulavarty <pbadari@us.ibm.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, sfr@canb.auug.org.au,
	ak@suse.de
To: Hugh Dickins <hugh@veritas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762322AbXEPPjy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705151927360.28895@blonde.wat.veritas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Hugh,

> It's interesting that compat_core_sys_select() shows this kmalloc(0)
> failure but core_sys_select() does not.  That's because core_sys_select()
> avoids kmalloc by using a buffer on the stack for small allocations (and
> 0 sure is small).  Shouldn't compat_core_sys_select() do just the same?
> Or is SLUB going to be so efficient that doing so is a waste of time?

Nice catch, the original optimisation from Andi is:

http://git.kernel.org/git-new/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=70674f95c0a2ea694d5c39f4e514f538a09be36f

And I think it makes sense for the compat code to do it too.

Anton
