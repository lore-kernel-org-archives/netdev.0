From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Thu, 03 Mar 2016 21:16:07 +0100
Message-ID: <87lh5zpbaw.fsf@belgarion.home>
References: <20151202.235217.2201517065767030121.davem@davemloft.net>
	<87fuzjl69l.fsf@belgarion.home> <87k2mi4ysn.fsf@belgarion.home>
	<20160205.173021.1388372628450225378.davem@davemloft.net>
	<87fux6439s.fsf@belgarion.home>
	<CAE1WaKK2DqYYOTLmprbLuZVN-8--sZVyZVHgkcT4Jg7797S7HQ@mail.gmail.com>
	<8760xjzbc5.fsf@belgarion.home>
	<CAOMZO5DfQZrP-qNdPC5hJ_J+e-mX547SMq1wUC3NXWzyx84PMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Hitoshi Mitake <mitake.hitoshi@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:44161 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbcCCUQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 15:16:14 -0500
In-Reply-To: <CAOMZO5DfQZrP-qNdPC5hJ_J+e-mX547SMq1wUC3NXWzyx84PMw@mail.gmail.com>
	(Fabio Estevam's message of "Tue, 23 Feb 2016 15:15:50 -0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fabio Estevam <festevam@gmail.com> writes:

> On Sat, Feb 20, 2016 at 12:48 PM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:
>
>> Hello,
>>
>> I'll reping once more, to see if any of you could give this patch a try.
>> So far Hitoshi doesn't have the hardware anymore, so it leaves only Guennadi and
>> Fabio.
>>
>> If you could give it a try it would be great.
>>
>> For reference, the patch is here : https://lkml.org/lkml/2015/11/30/768
>
> I finally got access to a mx53ard board, applied your patch and
> managed to NFS boot without issues:
>
> [    1.739281] smsc911x f4000000.lan9220 eth0: SMSC911x/921x
> identified at 0xe0a80000, IRQ: 207
>
> Tested-by: Fabio Estevam <fabio.estevam@nxp.com>

Thanks Fabio for the test.

I also tried with a different different approach.

I built the different platforms (imx v6, etc ...) :
 - one version (a) on a vanilla v4.5-rc2
 - one version (b) on a vaniall v4.5-rc2 + this patch

For each of the builds, I took the preprocessed output of smc911x.c, and made a
diff between (a) and (b). The commands used were :
 - building in [1]
 - diffing in [2]

The result is [3]. I conclude from [3] that the driver cannot break for non PXA
platforms.

With Fabio's test and this demonstration, is enough to convince you to apply
this patch David ?

Cheers.

--
Robert

[1] Building
arm-linux-gnueabi-gcc -Wp,-MD,drivers/net/ethernet/smsc/.smc911x.o.d  -nostdinc
-isystem /usr/lib/gcc/arm-linux-gnueabi/4.9/include -I./arch/arm/include
-Iarch/arm/include/generated/uapi -Iarch/arm/include/generated  -Iinclude
-I./arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I./include/uapi
-Iinclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__
-mlittle-endian -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs
-fno-strict-aliasing -fno-common -Werror-implicit-function-declaration
-Wno-format-security -std=gnu89 -fno-dwarf2-cfi-asm -fno-omit-frame-pointer
-mapcs -mno-sched-prolog -fno-ipa-sra -mabi=aapcs-linux -mno-thumb-interwork
-mfpu=vfp -marm -D__LINUX_ARM_ARCH__=6 -march=armv6k -mtune=arm1136j-s
-msoft-float -Uarm -fno-delete-null-pointer-checks -O2
--param=allow-store-data-races=0 -Wframe-larger-than=1024 -fno-stack-protector
-Wno-unused-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls
-fno-var-tracking-assignments -Wdeclaration-after-statement -Wno-pointer-sign
-fno-strict-overflow -fconserve-stack -Werror=implicit-int
-Werror=strict-prototypes -Werror=date-time -DCC_HAVE_ASM_GOTO
-D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(smc911x)"
-D"KBUILD_MODNAME=KBUILD_STR(smc911x)" -E -o
drivers/net/ethernet/smsc/smc911x_with_rjk_patch.E
drivers/net/ethernet/smsc/smc911x.c

[2] Diffing
rj@belgarion:~/mio_linux/kernel$ diff -I "#.*" -u
 drivers/net/ethernet/smsc/smc911x_without_rjk_patch.E
 drivers/net/ethernet/smsc/smc911x_with_rjk_patch.E >
 drivers/net/ethernet/smsc/smc911x_sdiff.diff

[3] Result of diffing
--- drivers/net/ethernet/smsc/smc911x_without_rjk_patch.E	2016-02-21 16:19:27.882425010 +0100
+++ drivers/net/ethernet/smsc/smc911x_with_rjk_patch.E	2016-02-21 16:19:59.250424159 +0100
@@ -49141,6 +49141,34 @@
 
 
 
+# 1 "include/linux/dma/pxa-dma.h" 1
+
+
+
+enum pxad_chan_prio {
+ PXAD_PRIO_HIGHEST = 0,
+ PXAD_PRIO_NORMAL,
+ PXAD_PRIO_LOW,
+ PXAD_PRIO_LOWEST,
+};
+
+struct pxad_param {
+ unsigned int drcmr;
+ enum pxad_chan_prio prio;
+};
+
+struct dma_chan;
+
+
+
+
+static inline __attribute__((always_inline)) __attribute__((no_instrument_function)) bool pxad_filter_fn(struct dma_chan *chan, void *param)
+{
+ return false;
+}
+# 78 "drivers/net/ethernet/smsc/smc911x.c" 2
+
+
 
 # 1 "drivers/net/ethernet/smsc/smc911x.h" 1
 # 31 "drivers/net/ethernet/smsc/smc911x.h"
@@ -50670,6 +50698,9 @@
  unsigned int val, chip_id, revision;
  const char *version_string;
  unsigned long irq_flags;
+ struct dma_slave_config config;
+ dma_cap_mask_t mask;
+ struct pxad_param param;
 
  do { } while (0);
