From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Fix 64bit bugs in dscc44.c II
Date: Wed, 8 Oct 2003 19:00:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008170005.GB28793@wotan.suse.de>
References: <20031007175953.GA1802@averell> <20031008084205.5c81faac.davem@redhat.com> <20031008155548.GB16937@wotan.suse.de> <20031008090132.2b58c067.davem@redhat.com> <20031008160859.GD16937@wotan.suse.de> <20031008161149.GA8134@wotan.suse.de> <20031008091050.11b2acb7.davem@redhat.com> <20031008163345.GA28793@wotan.suse.de> <20031008093153.3daaa6b3.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, ak@muc.de, ncorbic@sangoma.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031008093153.3daaa6b3.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 08, 2003 at 09:31:53AM -0700, David S. Miller wrote:
> On Wed, 8 Oct 2003 18:33:45 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > Just do that then when you apply the patch. Would have been faster
> > than to write all these emails ;-)
> 
> I deleted the original patch, so you have to resend it to
> me anyways, so please make the fix I've suggested as you
> do this.
> 
> When I ask you to do these small fixes, I don't do it to make your
> life miserable, I do it because it allows me to review and apply
> patches at a higher rate and scale better.

At least for such one liner changes it doesn't look like an effective
method (I bet you could have done the change quicker than typing
the first mail).  

I checked the code and the code was already using a unsigned long
cast, so no changes are needed. Just the variable it stored the
pointer in was wrong.

Here's the patch again.

---------------------------

Fix 64bit issues in dscc4


diff -u linux-2.5-cleanup/drivers/net/wan/dscc4.c-o linux-2.5-cleanup/drivers/net/wan/dscc4.c
--- linux-2.5-cleanup/drivers/net/wan/dscc4.c-o	2003-12-01 14:04:34.000000000 +0100
+++ linux-2.5-cleanup/drivers/net/wan/dscc4.c	2003-12-02 16:55:14.298508864 +0100
@@ -980,7 +980,7 @@
  *
  * This code doesn't need to be efficient. Keep It Simple
  */
-static void dscc4_pci_reset(struct pci_dev *pdev, u32 ioaddr)
+static void dscc4_pci_reset(struct pci_dev *pdev, unsigned long ioaddr)
 {
 	int i;
 
@@ -1461,7 +1461,8 @@
 	struct dscc4_dev_priv *root = token;
 	struct dscc4_pci_priv *priv;
 	struct net_device *dev;
-	u32 ioaddr, state;
+	unsigned long ioaddr;
+	u32 state;
 	unsigned long flags;
 	int i, handled = 1;
 
@@ -1613,7 +1614,7 @@
 				goto try;
 		}
 		if (state & Xpr) {
-			u32 scc_addr, ring;
+			unsigned long scc_addr, ring;
 			int i;
 
 			/*
@@ -1954,7 +1955,7 @@
 {
 	struct dscc4_pci_priv *ppriv;
 	struct dscc4_dev_priv *root;
-	u32 ioaddr;
+	unsigned long ioaddr;
 	int i;
 
 	ppriv = pci_get_drvdata(pdev);
