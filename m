From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFC PATCH 00/11] next: mips: Fix default configurations
Date: Sat, 20 Sep 2014 17:46:15 -0700
Message-ID: <1411260386-6800-1-git-send-email-linux@roeck-us.net>
Cc: Randy Dunlap <rdunlap@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Anish Bhatt <anish@chelsio.com>, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 5d6be6a5d486 ('scsi_netlink : Make SCSI_NETLINK dependent on NET instead
of selecting NET') in linux-next changes 'select NET' to 'depends NET'. As a
result, many configurations which do not explicitly select CONFIG_NET are no
longer valid and need to be updated.

An alternative to this patch series would be to revert the original commit which
caused the problem. However, a simple revert is no longer possible due to
secondary commits changing more dependencies; an attempt to build
nlm_xlp_defconfig after reverting the commit still failed with a build error.
It would therefore be necessary to track down and revert all related commits.

This patch series attempts to fix the problem for the affected mips
configurations. I did not look into other architectures or configurations.

The command sequence to create the new configuration files is as follows.

- Run "make ARCH=mips <configuration>" on upstream kernel
- Copy resulting .config to next-20140919
- Run "make ARCH=mips olddefconfig" in next-20140919
- Run "make ARCH=mips savedefconfig"
- Copy resulting defconfig file to arch/mips/configs/<configuration>
- Build the image with the resulting configuration

This sequence results in building images for all modified configurations,
but due to secondary dependency changes can not guarantee correctness
or completeness. Only time will show if there are more problems.
