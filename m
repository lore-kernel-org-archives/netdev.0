From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] net/hp100: fix section mismatch warning
Date: Thu, 31 May 2007 22:08:40 +0200
Message-ID: <20070531200840.GB27305@uranus.ravnborg.org>
References: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com> <465EE7BB.4050605@redhat.com> <20070531200446.GA27305@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	"Luck, Tony" <tony.luck@intel.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	David Chinner <dgc@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
To: Prarit Bhargava <prarit@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-ia64-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070531200446.GA27305@uranus.ravnborg.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix following section mismatch warning in hp100:

WARNING: drivers/net/hp100.o(.init.text+0x26a): Section mismatch: reference to .exit.text: (after 'init_module')

The warning says that we use a function marked __exit from a 
function marked __init.
This is not good on architectures where we discard __exit section
for drivers that are built-in.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
Comple tested only.

Note: This warning does not appear with modpost in upstream kernel
      but I would like to submit patches for the obvious bugs ASAP

	Sam

diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 8118a67..8caa591 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -3005,7 +3005,7 @@ static int __init hp100_isa_init(void)
 	return cards > 0 ? 0 : -ENODEV;
 }
 
-static void __exit hp100_isa_cleanup(void)
+static void hp100_isa_cleanup(void)
 {
 	int i;
 
