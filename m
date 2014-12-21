From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 02/11] timecounter: provide a helper function to shift the time.
Date: Sun, 21 Dec 2014 19:46:57 +0100
Message-ID: <cb154598f15dff99f244f957a0a5cac2f5512461.1418504889.git.richardcochran@gmail.com>
References: <cover.1418504883.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1418504883.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some PTP Hardware Clock drivers use a struct timecounter to represent
their clock. To adjust the time by a given offset, these drivers all
perform a two step read/write of their timecounter. However, it is
better and simpler just to adjust the offset in one step. This patch
introduces a little routine to help drivers implement the adjtime
method.

Suggested-by: Janusz U=C5=BCycki <j.uzycki@elproma.com.pl>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 include/linux/timecounter.h |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/timecounter.h b/include/linux/timecounter.h
index 146f07a..af3dfa4 100644
--- a/include/linux/timecounter.h
+++ b/include/linux/timecounter.h
@@ -79,6 +79,15 @@ static inline u64 cyclecounter_cyc2ns(const struct c=
yclecounter *cc,
 }
=20
 /**
+ * timecounter_adjtime - Shifts the time of the clock.
+ * @delta:	Desired change in nanoseconds.
+ */
+static inline void timecounter_adjtime(struct timecounter *tc, s64 del=
ta)
+{
+	tc->nsec +=3D delta;
+}
+
+/**
  * timecounter_init - initialize a time counter
  * @tc:			Pointer to time counter which is to be initialized/reset
  * @cc:			A cycle counter, ready to be used.
--=20
1.7.10.4
