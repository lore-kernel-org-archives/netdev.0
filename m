From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 01/39] wimax: documentation for the stack
Date: Wed, 26 Nov 2008 14:40:20 -0800
Message-ID: <30bd4ebdff036493508a388892c200fe2b70c7fb.1227691434.git.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:43324 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752121AbYKZWlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 17:41:11 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 Documentation/wimax/README.wimax |   86 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 86 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/wimax/README.wimax

diff --git a/Documentation/wimax/README.wimax b/Documentation/wimax/README.wimax
new file mode 100644
index 0000000..5f6a0a1
--- /dev/null
+++ b/Documentation/wimax/README.wimax
@@ -0,0 +1,86 @@
+   Linux kernel WiMAX stack
+
+   (C) 2008 Intel Corporation < linux-wimax@intel.com >
+
+   This provides a basic Linux kernel WiMAX stack to provide a common
+   control API for WiMAX devices, usable from kernel and user space.
+
+Design
+
+   The WiMAX stack is designed to provide for common WiMAX control
+   services to current and future WiMAX devices from any vendor.
+
+   Because currently there is only one and we don't know what would be the
+   common services, the APIs it currently provides are very minimal.
+   However, it is done in such a way that it is easily extensible to
+   accommodate future requirements.
+
+   The stack works by embedding a struct wimax_dev in your device's
+   control structures. This provides a set of callbacks that the WiMAX
+   stack will call in order to implement control operations requested by
+   the user. As well, the stack provides API functions that the driver
+   calls to notify about changes of state in the device.
+
+   The stack exports the API calls needed to control the device to user
+   space using generic netlink as a marshalling mechanism. You can access
+   them using your own code or use the wrappers provided for your
+   convenience in libwimax (in the wimax-tools package).
+
+   For detailed information on the stack, please see
+   include/net/wimax.h.
+
+Usage
+
+   For usage in a driver (registration, API, etc) please refer to the
+   instructions in the header file include/net/wimax.h.
+
+   When a device is registered with the WiMAX stack, a set of control
+   files will appear under the wimax/ subdirectory in the device's sysfs
+   directory that the user can tweak for control.
+
+   The device's sysfs directory can be found with find:
+
+$ find /sys/devices -name net:wmx0
+/sys/devices/pci0000:00/0000:00:1d.7/usb5/5-2/5-2:1.0/net:wmx0
+
+   Where wmx0 is the network device name of your device. Note the paths
+   will vary from system to system.
+
+sysfs: controlling debug output from the stack
+
+   The WiMAX stack is compiled, by default, with debug messages that can
+   be used to diagnose issues. By default, said messages are disabled.
+
+   By tweaking the values reported in the wimax/debug-levels file, each
+   submodule in the stack can be made to be verbose about its operation.
+
+   To see the current debug levels:
+
+$ cd /sys/devices/...../net:wmx0
+$ cat wimax/debug_levels
+0 id_table
+7 op_msg
+0 op_open
+0 op_reset
+0 op_rfkill
+0 stack
+
+   In this example, the id_table submodule has a debug level of 7 (very
+   verbose).
+
+   To increase the debug level of, for example, the op_rfkill sumodule,
+   just write:
+
+$ echo 3 op_rfkill > wimax/debug_levels
+
+   Increasing numbers yield increasing debug information; for details of
+   what is each, check the source.
+
+   To reset any level to minimum operation, set its level to zero.
+
+sysfs: finding generic netlink information (deprecated)
+
+   The files wimax/gnl_family_id and wimax/gnl_version contain information
+   about the generic netlink registration for each device.
+
+   These files are deprecated.
-- 
1.5.6.5

