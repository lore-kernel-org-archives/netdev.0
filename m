From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v2] x86: make DR*_RESERVED unsigned long
Date: Fri, 26 Apr 2013 18:38:02 +0200
Message-ID: <20130426163802.GA30351@redhat.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com> <20130424072630.GB1780@gmail.com> <20130424170702.GA1867@redhat.com> <5178282D.9030902@zytor.com> <20130425144818.GA25921@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
	Fr??d??ric Weisbecker <fweisbec@gmail.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130425144818.GA25921@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DR6_RESERVED and DR_CONTROL_RESERVED are used to clear the set
bits in the "unsigned long" data, make them long to ensure that
"&~" doesn't clear the upper bits.

This is only cleanup, the usage of ~DR*_RESERVED is safe but
doesn't look clean and the pattern is error prone.

	- do_debug:

		dr6 &= ~DR6_RESERVED;

	  this also wrongly clears 32-63 bits. Fortunately these
	  bits are reserved and must be zero.

	- ptrace_write_dr7:

		data &= ~DR_CONTROL_RESERVED;

	  on __i386__ this mixes long/int but sizeof should be the
	  same.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 arch/x86/include/uapi/asm/debugreg.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/uapi/asm/debugreg.h b/arch/x86/include/uapi/asm/debugreg.h
index 3c0874d..c0c1b89 100644
--- a/arch/x86/include/uapi/asm/debugreg.h
+++ b/arch/x86/include/uapi/asm/debugreg.h
@@ -15,7 +15,7 @@
    are either reserved or not of interest to us. */
 
 /* Define reserved bits in DR6 which are always set to 1 */
-#define DR6_RESERVED	(0xFFFF0FF0)
+#define DR6_RESERVED	(0xFFFF0FF0UL)
 
 #define DR_TRAP0	(0x1)		/* db0 */
 #define DR_TRAP1	(0x2)		/* db1 */
@@ -65,7 +65,7 @@
    gdt or the ldt if we want to.  I am not sure why this is an advantage */
 
 #ifdef __i386__
-#define DR_CONTROL_RESERVED (0xFC00) /* Reserved by Intel */
+#define DR_CONTROL_RESERVED (0xFC00UL) /* Reserved by Intel */
 #else
 #define DR_CONTROL_RESERVED (0xFFFFFFFF0000FC00UL) /* Reserved */
 #endif
-- 
1.5.5.1
