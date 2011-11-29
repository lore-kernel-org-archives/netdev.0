From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next v4 0/4] can: cc770: add support
	for the Bosch CC770 and Intel AN82527
Date: Tue, 29 Nov 2011 10:11:26 +0100
Message-ID: <1322557890-6363-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Already since a while we have support for the Bosch CC770 and Intel
AN82527 CAN controllers in our out-of-tree Socket-CAN repository.

In the meantime I found a TQM855L board with two AN82527 on it,
which allowed me to provide and test a generic platform driver
as well.

Changes since v1:

- remove version.h includes
- some minor corrections in the ISA bus driver
- add platform header file to the driver core
- add generic platform driver
- add and update device tree nodes for tqm8xx and tqm8548

Changes since v2:

- correct license text as suggest by Oliver Hartkopp
- use the new module_platform_driver function
- provide get_berr_counter callback for cc770
- improve CAN error state change handling
- more comprehensive cc770_isa driver description

Changes since v3:

- pre-define pr_fmt()
- use KBUILD_MODNAME instead of DRV_NAME
- use ARRAY_SIZE() whenever appropriate
- use variable name "o" for message objects consistantly
- use proper error code for cc770_probe_chip
- remove unneeded member priv->open_time
- remove unnecessary masking of u8 variables (with 0xff)
- use "!skb" instead of "skb == NULL"
- CC770_MSG_MAX now limits the number of messages read in the ISR
- use "|" instead of "+" to combine bit masks
- remove return code check of platform_get_resource() in remove function
- remove postal address from GPL copyright text
- fix WARNING: __packed is preferred over __attribute__((packed))
- some more minor fixes (casts, white space, etc.)

It would be nice if somebody else could test the driver, especially
the ISA driver (I don't have hardware at hand).

Wolfgang.

Wolfgang Grandegger (4):
  can: cc770: add driver core for the Bosch CC770 and Intel AN82527
  can: cc770: add legacy ISA bus driver for the CC770 and AN82527
  can: cc770: add platform bus driver for the CC770 and AN82527
  powerpc: tqm8548/tqm8xx: add and update CAN device nodes

 .../devicetree/bindings/net/can/cc770.txt          |   56 ++
 arch/powerpc/boot/dts/tqm8548-bigflash.dts         |   19 +-
 arch/powerpc/boot/dts/tqm8548.dts                  |   19 +-
 arch/powerpc/boot/dts/tqm8xx.dts                   |   25 +
 drivers/net/can/Kconfig                            |    2 +
 drivers/net/can/Makefile                           |    1 +
 drivers/net/can/cc770/Kconfig                      |   21 +
 drivers/net/can/cc770/Makefile                     |    9 +
 drivers/net/can/cc770/cc770.c                      |  881 ++++++++++++++++++++
 drivers/net/can/cc770/cc770.h                      |  203 +++++
 drivers/net/can/cc770/cc770_isa.c                  |  366 ++++++++
 drivers/net/can/cc770/cc770_platform.c             |  273 ++++++
 include/linux/can/platform/cc770.h                 |   33 +
 13 files changed, 1898 insertions(+), 10 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/cc770.txt
 create mode 100644 drivers/net/can/cc770/Kconfig
 create mode 100644 drivers/net/can/cc770/Makefile
 create mode 100644 drivers/net/can/cc770/cc770.c
 create mode 100644 drivers/net/can/cc770/cc770.h
 create mode 100644 drivers/net/can/cc770/cc770_isa.c
 create mode 100644 drivers/net/can/cc770/cc770_platform.c
 create mode 100644 include/linux/can/platform/cc770.h

-- 
1.7.4.1
