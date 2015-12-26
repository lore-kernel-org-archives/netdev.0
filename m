From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [PATCH v2] coccinelle: api: check for propagation of error from
 platform_get_irq
Date: Sat, 26 Dec 2015 21:58:58 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1512262156580.2070@localhost6.localdomain6>
References: <1451157891-24881-1-git-send-email-Julia.Lawall@lip6.fr> <567EF188.7020203@cogentembedded.com> <alpine.DEB.2.02.1512262107340.2070@localhost6.localdomain6> <alpine.DEB.2.02.1512262123500.2070@localhost6.localdomain6>
 <567EF895.6080702@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org
To: Gilles Muller <Gilles.Muller@lip6.fr>,
	Nicolas Palix <nicolas.palix@imag.fr>,
	Michal Marek <mmarek@suse.com>, cocci@systeme.lip6.fr,
	linux-kernel@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-i2c@vger.kernel.org, linux-spi@vger.kernel.org,
	dri-devel@lists.freedesktop.org
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <567EF895.6080702@cogentembedded.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The error return value of platform_get_irq seems to often get dropped.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

v2: Check for the direct return case also.  Added some mailing lists of
common offenders.

diff --git a/scripts/coccinelle/api/platform_get_irq_return.cocci b/scripts/coccinelle/api/platform_get_irq_return.cocci
new file mode 100644
index 0000000..44680d0
--- /dev/null
+++ b/scripts/coccinelle/api/platform_get_irq_return.cocci
@@ -0,0 +1,58 @@
+/// Propagate the return value of platform_get_irq.
+//# Sometimes the return value of platform_get_irq is tested using <= 0, but 0
+//# might not be an appropriate return value in an error case.
+///
+// Confidence: Moderate
+// Copyright: (C) 2015 Julia Lawall, Inria. GPLv2.
+// URL: http://coccinelle.lip6.fr/
+// Options: --no-includes --include-headers
+
+virtual context
+virtual org
+virtual report
+
+// ----------------------------------------------------------------------------
+
+@r depends on context || org || report@
+constant C;
+statement S;
+expression e, ret;
+position j0, j1;
+@@
+
+* e@j0 = platform_get_irq(...);
+(
+if@j1 (...) {
+  ...
+  return -C;
+} else S
+|
+if@j1 (...) {
+  ...
+  ret = -C;
+  ...
+  return ret;
+} else S
+)
+
+// ----------------------------------------------------------------------------
+
+@script:python r_org depends on org@
+j0 << r.j0;
+j1 << r.j1;
+@@
+
+msg = "Propagate return value of platform_get_irq."
+coccilib.org.print_todo(j0[0], msg)
+coccilib.org.print_link(j1[0], "")
+
+// ----------------------------------------------------------------------------
+
+@script:python r_report depends on report@
+j0 << r.j0;
+j1 << r.j1;
+@@
+
+msg = "Propagate return value of platform_get_irq around line %s." % (j1[0].line)
+coccilib.report.print_report(j0[0], msg)
+
