From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 08/45] CPU hotplug: Convert preprocessor macros to static
 inline functions
Date: Tue, 22 Jan 2013 13:05:02 +0530
Message-ID: <20130122073500.13822.11469.stgit@srivatsabhat.in.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
 nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org, fweisbec@gmail.com,
 linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org,
 xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
 wangyun@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
 netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-arm-kernel@lists.infradead.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org, oleg@redhat.com,
 paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au, mingo@kernel.org,
 akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 12/05/2012 06:10 AM, Andrew Morton wrote:
"static inline C functions would be preferred if possible.  Feel free to
fix up the wrong crufty surrounding code as well ;-)"

Convert the macros in the CPU hotplug code to static inline C functions.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/cpu.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index cf24da1..eb79f47 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -198,10 +198,10 @@ static inline void cpu_hotplug_driver_unlock(void)
 
 #else		/* CONFIG_HOTPLUG_CPU */
 
-#define get_online_cpus()	do { } while (0)
-#define put_online_cpus()	do { } while (0)
-#define get_online_cpus_atomic()	do { } while (0)
-#define put_online_cpus_atomic()	do { } while (0)
+static inline void get_online_cpus(void) {}
+static inline void put_online_cpus(void) {}
+static inline void get_online_cpus_atomic(void) {}
+static inline void put_online_cpus_atomic(void) {}
 #define hotcpu_notifier(fn, pri)	do { (void)(fn); } while (0)
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
