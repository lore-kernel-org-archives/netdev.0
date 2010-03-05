From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 0/3] recursive printk, make functions from logging macros
Date: Thu,  4 Mar 2010 22:56:51 -0800
Message-ID: <cover.1267771398.git.joe@perches.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_<level> macros use a lot of repetitive string space and arguments
pr_<level> macros use repetitive unnecessary KERN_<level> strings

Eliminate the string prefixes and function arguments from all the macro uses
and consolidate them in functions.

This patchset saves about 60K of text in an x86 defconfig.

This implementation adds the ability to use a struct va_format to
emit a format string along with va_list arguments.

This %pV implementation should not be used without a wrapper that
does printf argument verification like the dev_<level> functions.

Inspired a bit by Nick Andrew's patches and Linus' comments in December 2008
http://lkml.org/lkml/2008/12/6/15
http://lkml.org/lkml/2008/12/6/101

Joe Perches (3):
  vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
  device.h drivers/base/core.c Convert dev_<level> macros to functions
  kernel.h kernel/printk.c: Convert pr_<level> macros to functions

 drivers/base/core.c    |   56 +++++++++++++++++++++++++
 include/linux/device.h |  105 ++++++++++++++++++++++++++++++++++++------------
 include/linux/kernel.h |   75 +++++++++++++++++++++++++++-------
 kernel/printk.c        |   26 ++++++++++++
 lib/vsprintf.c         |    9 ++++
 5 files changed, 229 insertions(+), 42 deletions(-)
