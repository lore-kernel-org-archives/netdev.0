From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH next v2] drivers/net/wireless/ath/wil6210/debugfs.c: Use 'uint64_t'
 instead of 'cycles_t' to avoid warnings
Date: Wed, 24 Dec 2014 23:08:44 +0800
Message-ID: <549AD6FC.8060706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org
To: qca_vkondrat@qca.qualcomm.com, kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34242 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbaLXPIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 10:08:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

do_div() checks the type strictly. 'cycles_t' may be 32-bit under quite
a few architectures (parisc, arm, avr32 ...). So use 'uint64_t' instead
of, the related warning (with allmodconfig under parisc):

    CC [M]  drivers/net/wireless/ath/wil6210/debugfs.o
  In file included from arch/parisc/include/generated/asm/div64.h:1:0,
                   from include/linux/kernel.h:124,
                   from include/linux/list.h:8,
                   from include/linux/module.h:9,
                   from drivers/net/wireless/ath/wil6210/debugfs.c:17:
  drivers/net/wireless/ath/wil6210/debugfs.c: In function =E2=80=98wil_=
vring_debugfs_show=E2=80=99:
  include/asm-generic/div64.h:43:28: warning: comparison of distinct po=
inter types lacks a cast
    (void)(((typeof((n)) *)0) =3D=3D ((uint64_t *)0)); \
                              ^
  drivers/net/wireless/ath/wil6210/debugfs.c:107:4: note: in expansion =
of macro =E2=80=98do_div=E2=80=99
      do_div(idle, total);
      ^
  In file included from include/uapi/linux/stddef.h:1:0,
                   from include/linux/stddef.h:4,
                   from ./include/uapi/linux/posix_types.h:4,
                   from include/uapi/linux/types.h:13,
                   from include/linux/types.h:5,
                   from include/linux/list.h:4,
                   from include/linux/module.h:9,
                   from drivers/net/wireless/ath/wil6210/debugfs.c:17:
  include/asm-generic/div64.h:44:18: warning: right shift count >=3D wi=
dth of type [-Wshift-count-overflow]
    if (likely(((n) >> 32) =3D=3D 0)) {   \
                    ^
  include/linux/compiler.h:159:40: note: in definition of macro =E2=80=98=
likely=E2=80=99
   # define likely(x) __builtin_expect(!!(x), 1)
                                          ^
  drivers/net/wireless/ath/wil6210/debugfs.c:107:4: note: in expansion =
of macro =E2=80=98do_div=E2=80=99
      do_div(idle, total);
      ^
  In file included from arch/parisc/include/generated/asm/div64.h:1:0,
                   from include/linux/kernel.h:124,
                   from include/linux/list.h:8,
                   from include/linux/module.h:9,
                   from drivers/net/wireless/ath/wil6210/debugfs.c:17:
  include/asm-generic/div64.h:48:22: warning: passing argument 1 of =E2=
=80=98__div64_32=E2=80=99 from incompatible pointer type [-Wincompatibl=
e-pointer-types]
     __rem =3D __div64_32(&(n), __base); \
                        ^
  drivers/net/wireless/ath/wil6210/debugfs.c:107:4: note: in expansion =
of macro =E2=80=98do_div=E2=80=99
      do_div(idle, total);
      ^
  include/asm-generic/div64.h:35:17: note: expected =E2=80=98uint64_t *=
 {aka long long unsigned int *}=E2=80=99 but argument is of type =E2=80=
=98cycles_t * {aka long unsigned int *}=E2=80=99
   extern uint32_t __div64_32(uint64_t *dividend, uint32_t divisor);
                   ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/wireless/ath/wil6210/debugfs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wil6210/debugfs.c b/drivers/net/w=
ireless/ath/wil6210/debugfs.c
index 4e6e145..cd991fa 100644
--- a/drivers/net/wireless/ath/wil6210/debugfs.c
+++ b/drivers/net/wireless/ath/wil6210/debugfs.c
@@ -101,8 +101,8 @@ static int wil_vring_debugfs_show(struct seq_file *=
s, void *data)
 			char name[10];
 			/* performance monitoring */
 			cycles_t now =3D get_cycles();
-			cycles_t idle =3D txdata->idle * 100;
-			cycles_t total =3D now - txdata->begin;
+			uint64_t idle =3D txdata->idle * 100;
+			uint64_t total =3D now - txdata->begin;
=20
 			do_div(idle, total);
 			txdata->begin =3D now;
--=20
1.7.9.5
