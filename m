From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH v2] xtables: make XT_ALIGN() usable in exported headers
 by exporting __ALIGN_KERNEL()
Date: Tue, 13 Apr 2010 11:50:03 +0000 (UTC)
Message-ID: <20100414125007.GB25686@x200>
References: <20100407162245.GA4557@x200>
 <4BC437C6.8020602@trash.net>
 <4BC44117.80901@trash.net>
 <20100414120712.GA25686@x200>
 <4BC450A4.1010200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, bhutchings@solarflare.com, andreas@fatal.se,
	hadi@cyberus.ca, hideaki@yoshifuji.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Date: Wed, 14 Apr 2010 15:50:07 +0300
Content-Disposition: inline
In-Reply-To: <4BC450A4.1010200@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 13, 2010 at 01:08:20PM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
> > XT_ALIGN() was rewritten through ALIGN() by commit 42107f5009da223daa800d6da6904d77297ae829
> > "netfilter: xtables: symmetric COMPAT_XT_ALIGN definition".
> > ALIGN() is not exported in userspace headers, which created compile problem for tc(8)
> > and will create problem for iptables(8).
> > 
> > We can't export generic looking name ALIGN() but we can export less generic
> > __ALIGN_KERNEL() (suggested by Ben Hutchings).
> > Google knows nothing about __ALIGN_KERNEL().
> > 
> > COMPAT_XT_ALIGN() changed for symmetry.
> 
> I've already pushed your change out, could you send me an incremental
> fix please?
> 
> master.kernel.org:/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

[PATCH] Restore __ALIGN_MASK()

Fix lib/bitmap.c compile failure due to __ALIGN_KERNEL changes.

---
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -40,6 +40,7 @@ extern const char linux_proc_banner[];
 #define STACK_MAGIC	0xdeadbeef
 
 #define ALIGN(x, a)		__ALIGN_KERNEL((x), (a))
+#define __ALIGN_MASK(x, mask)	__ALIGN_KERNEL_MASK((x), (mask))
 #define PTR_ALIGN(p, a)		((typeof(p))ALIGN((unsigned long)(p), (a)))
 #define IS_ALIGNED(x, a)		(((x) & ((typeof(x))(a) - 1)) == 0)
 
