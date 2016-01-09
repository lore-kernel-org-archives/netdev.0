From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: [net-next] ksz9031_config_init(): error: 'struct phy_device' has no
 member named 'dev' dev_walker = &phydev->dev;
Date: Sat, 9 Jan 2016 11:19:34 +0100
Message-ID: <CA+icZUVUB7YtodE5shsMtB83BYF3fMEL2ypK5YFqZapC8dqeNQ@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Daney <david.daney@cavium.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:34428 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbcAIKTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 05:19:35 -0500
Received: by mail-vk0-f51.google.com with SMTP id a123so173012859vkh.1
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 02:19:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just FYI...

With recent net-next.git#master up to commit
d86cdfcd5d7e1179e695977b7088882822f365c4 ("Merge branch
'r8152-adjustments'")...
...and...
CONFIG_NET_VENDOR_MICREL=y
CONFIG_MICREL_PHY=y
# CONFIG_MICREL_KS8995MA is not set
...
I get the following build-error:

$ mycompiler -Wp,-MD,drivers/net/phy/.micrel.o.d  -nostdinc -isystem
/usr/lib/gcc/x86_64-linux-gnu/4.9/include -nostdinc -isystem
/usr/lib/gcc/x86_64-linux-gnu/4.9/include -I./arch/x86/include
-Iarch/x86/include/generated/uapi -Iarch/x86/include/generated
-Iinclude -I./arch/x86/include/uapi -Iarch/x86/include/generated/uapi
-I./include/uapi -Iinclude/generated/uapi -include
./include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef
-Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common
-Werror-implicit-function-declaration -Wno-format-security -std=gnu89
-mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -m64 -falign-jumps=1
-falign-loops=1 -mno-80387 -mno-fp-ret-in-387
-mpreferred-stack-boundary=3 -mtune=generic -mno-red-zone
-mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args
-DCONFIG_X86_X32_ABI -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1
-DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_SSSE3=1
-DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -DCONFIG_AS_AVX2=1 -pipe
-Wno-sign-compare -fno-asynchronous-unwind-tables
-fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0
-Wframe-larger-than=1024 -fno-stack-protector
-Wno-unused-but-set-variable -fno-omit-frame-pointer
-fno-optimize-sibling-calls -fno-var-tracking-assignments -pg -mfentry
-DCC_USING_FENTRY -Wdeclaration-after-statement -Wno-pointer-sign
-fno-strict-overflow -fconserve-stack -Werror=implicit-int
-Werror=strict-prototypes -Werror=date-time -DCC_HAVE_ASM_GOTO
-D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(micrel)"
-D"KBUILD_MODNAME=KBUILD_STR(micrel)" -c -o
drivers/net/phy/.tmp_micrel.o drivers/net/phy/micrel.c
drivers/net/phy/micrel.c: In function 'ksz9031_config_init':
drivers/net/phy/micrel.c:492:22: error: 'struct phy_device' has no
member named 'dev'
  dev_walker = &phydev->dev;
                      ^
make[5]: *** [drivers/net/phy/micrel.o] Error 1
make[4]: *** [drivers/net/phy] Error 2
make[3]: *** [drivers/net] Error 2
make[2]: *** [drivers] Error 2

That's the hunk of changes in micrel.c:

@@ -276,7 +288,8 @@ static int kszphy_config_init(struct phy_device *phydev)
        if (priv->rmii_ref_clk_sel) {
                ret = kszphy_rmii_clk_sel(phydev, priv->rmii_ref_clk_sel_val);
                if (ret) {
-                       dev_err(&phydev->dev, "failed to set rmii
reference clock\n");
+                       phydev_err(phydev,
+                                  "failed to set rmii reference clock\n");
                        return ret;
                }
        }

I saw no patches on patchwork.

Hope this helps...

Regards,
- Sedat -

[1] https://patchwork.ozlabs.org/project/netdev/list/
