From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH linux-next] net/dccp/timer.c: use 'u64' instead of 's64' to
 avoid compiler's warning
Date: Wed, 21 May 2014 08:19:34 +0800
Message-ID: <537BF116.9000900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: gerrit@erg.abdn.ac.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'dccp_timestamp_seed' is initialized once by ktime_get_real() in
dccp_timestamping_init(). It is always less than ktime_get_real()
in dccp_timestamp().

Then, ktime_us_delta() in dccp_timestamp() will always return positive
number. So can use manual type cast to let compiler and do_div() know
about it to avoid warning.

The related warning (with allmodconfig under unicore32):

    CC [M]  net/dccp/timer.o
  net/dccp/timer.c: In function =91dccp_timestamp=92:
  net/dccp/timer.c:285: warning: comparison of distinct pointer types l=
acks a cast


Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 net/dccp/timer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 16f0b22..1cd46a3 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -280,7 +280,7 @@ static ktime_t dccp_timestamp_seed;
  */
 u32 dccp_timestamp(void)
 {
-	s64 delta =3D ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
+	u64 delta =3D (u64)ktime_us_delta(ktime_get_real(), dccp_timestamp_se=
ed);
=20
 	do_div(delta, 10);
 	return delta;
--=20
1.9.2.459.g68773ac
