From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70
	check_irq_resend()
Date: Fri, 10 Aug 2007 12:16:41 +0200
Message-ID: <20070810101641.GA31396@elte.hu>
References: <18107.11431.838905.331157@stoffel.org> <20070809155445.GA5161@ff.dom.local> <1186733140.12828.45.camel@chaos> <20070810082346.GD1764@ff.dom.local> <20070810083050.GA4545@elte.hu> <20070810084924.GF1764@ff.dom.local> <20070810085611.GA11639@elte.hu> <20070810091231.GH1764@ff.dom.local> <20070810093353.GA19777@elte.hu> <20070810100513.GA3279@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	marcin.slusarz@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070810100513.GA3279@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> Ingo: I think, you have to do this in x86_64, and there is probably 
> send_IPI_mask used for this (but I can miss something...).

indeed - full patch below.

	Ingo

---
 arch/i386/kernel/io_apic.c   |    3 ++-
 arch/x86_64/kernel/genapic.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

Index: linux/arch/i386/kernel/io_apic.c
===================================================================
--- linux.orig/arch/i386/kernel/io_apic.c
+++ linux/arch/i386/kernel/io_apic.c
@@ -735,7 +735,8 @@ void fastcall send_IPI_self(int vector)
 	 * Wait for idle.
 	 */
 	apic_wait_icr_idle();
-	cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL;
+	cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL |
+		APIC_INT_LEVELTRIG;
 	/*
 	 * Send the IPI. The write to APIC_ICR fires this off.
 	 */
Index: linux/arch/x86_64/kernel/genapic.c
===================================================================
--- linux.orig/arch/x86_64/kernel/genapic.c
+++ linux/arch/x86_64/kernel/genapic.c
@@ -62,5 +62,6 @@ void __init setup_apic_routing(void)
 
 void send_IPI_self(int vector)
 {
-	__send_IPI_shortcut(APIC_DEST_SELF, vector, APIC_DEST_PHYSICAL);
+	__send_IPI_shortcut(APIC_DEST_SELF, vector, APIC_DEST_PHYSICAL |
+			    APIC_INT_LEVELTRIG);
 }
