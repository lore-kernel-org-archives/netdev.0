From: Joe Perches <joe@perches.com>
Subject: [PATCH] 3c505: Fix compile breakage
Date: Mon, 31 Oct 2011 23:45:24 +0200
Message-ID: <1320097524.4399.8.camel@Joe-Laptop>
References: <4EAF0F34.4070702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Philip Blundell <philb@gnu.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Boaz Harrosh <bharrosh@panasas.com>,
	Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EAF0F34.4070702@panasas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The joys of preprocessor games with c90 named initializers.

commit 07613b0b5ef8
("dynamic_debug: consolidate repetitive struct _ddebug descriptor definitions")
uses a ".filename" named initializer.

When filename is also a #define this fails to compile.

Remove #define filename from 3c505.c

Signed-off-by: Joe Perches <joe@perches.com>

---

On Mon, 2011-10-31 at 14:12 -0700, Boaz Harrosh wrote:
> Doing an "make ARCH=i386 allmodconfig" on  linus/master  [f362f98] gives me the below
> compilation breakage.
> (Fedora_15_amd64 machine)
> It's probably old news but I thought I'll report it as part of my obligation
> as a Kernel monkey

Thanks Boaz.

Good monkey, <gives peanut>

 drivers/net/ethernet/i825xx/3c505.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/i825xx/3c505.c b/drivers/net/ethernet/i825xx/3c505.c
index 40e1a17..ba82a26 100644
--- a/drivers/net/ethernet/i825xx/3c505.c
+++ b/drivers/net/ethernet/i825xx/3c505.c
@@ -126,15 +126,13 @@
  *
  *********************************************************/
 
-#define filename __FILE__
-
 #define timeout_msg "*** timeout at %s:%s (line %d) ***\n"
 #define TIMEOUT_MSG(lineno) \
-	pr_notice(timeout_msg, filename, __func__, (lineno))
+	pr_notice(timeout_msg, __FILE__, __func__, (lineno))
 
 #define invalid_pcb_msg "*** invalid pcb length %d at %s:%s (line %d) ***\n"
 #define INVALID_PCB_MSG(len) \
-	pr_notice(invalid_pcb_msg, (len), filename, __func__, __LINE__)
+	pr_notice(invalid_pcb_msg, (len), __FILE__, __func__, __LINE__)
 
 #define search_msg "%s: Looking for 3c505 adapter at address %#x..."
 
