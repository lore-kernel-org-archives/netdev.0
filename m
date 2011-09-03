From: Harvey Yang <harvey.huawei.yang@gmail.com>
Subject: [PATCH] =?UTF-8?q?drivers/isdn/sc/init.c:=20Fix=20warning:passing=20argument=201=20of=20=E2=80=98readl=E2=80=99=20makes=20pointer=20from=20integer=20without=20a=20cast?=
Date: Sat,  3 Sep 2011 10:02:19 +0800
Message-ID: <1315015339-2501-1-git-send-email-harvey.huawei.yang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Harvey Yang <harvey.huawei.yang@gmail.com>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/isdn/sc/init.c:487: warning: passing argument 1 of =E2=80=98rea=
dl=E2=80=99 makes pointer from integer without a cast
/home/harvey/Projects/linux-kernel/linux-2.6/arch/x86/include/asm/io.h:=
55: note: expected =E2=80=98const volatile void *=E2=80=99 but argument=
 is of type =E2=80=98long unsigned int=E2=80=99
drivers/isdn/sc/init.c:497: warning: passing argument 1 of =E2=80=98rea=
dl=E2=80=99 makes pointer from integer without a cast
/home/harvey/Projects/linux-kernel/linux-2.6/arch/x86/include/asm/io.h:=
55: note: expected =E2=80=98const volatile void *=E2=80=99 but argument=
 is of type =E2=80=98long unsigned int=E2=80=99
drivers/isdn/sc/init.c:507: warning: passing argument 1 of =E2=80=98rea=
dl=E2=80=99 makes pointer from integer without a cast
/home/harvey/Projects/linux-kernel/linux-2.6/arch/x86/include/asm/io.h:=
55: note: expected =E2=80=98const volatile void *=E2=80=99 but argument=
 is of type =E2=80=98long unsigned int=E2=80=99

Signed-off-by: Harvey Yang <harvey.huawei.yang@gmail.com>
---
 drivers/isdn/sc/init.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/sc/init.c b/drivers/isdn/sc/init.c
index ca710ab..d3db30d 100644
--- a/drivers/isdn/sc/init.c
+++ b/drivers/isdn/sc/init.c
@@ -484,7 +484,7 @@ static int identify_board(unsigned long rambase, un=
signed int iobase)
 	 */
 	outb(PRI_BASEPG_VAL, pgport);
 	msleep_interruptible(1000);
-	sig =3D readl(rambase + SIG_OFFSET);
+	sig =3D readl((const volatile void *)(rambase + SIG_OFFSET));
 	pr_debug("Looking for a signature, got 0x%lx\n", sig);
 	if(sig =3D=3D SIGNATURE)
 		return PRI_BOARD;
@@ -494,7 +494,7 @@ static int identify_board(unsigned long rambase, un=
signed int iobase)
 	 */
 	outb(BRI_BASEPG_VAL, pgport);
 	msleep_interruptible(1000);
-	sig =3D readl(rambase + SIG_OFFSET);
+	sig =3D readl((const volatile void *)(rambase + SIG_OFFSET));
 	pr_debug("Looking for a signature, got 0x%lx\n", sig);
 	if(sig =3D=3D SIGNATURE)
 		return BRI_BOARD;
@@ -504,7 +504,7 @@ static int identify_board(unsigned long rambase, un=
signed int iobase)
 	/*
 	 * Try to spot a card
 	 */
-	sig =3D readl(rambase + SIG_OFFSET);
+	sig =3D readl((const volatile void *)(rambase + SIG_OFFSET));
 	pr_debug("Looking for a signature, got 0x%lx\n", sig);
 	if(sig !=3D SIGNATURE)
 		return -1;
--=20
1.7.2.5
