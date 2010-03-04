From: Joe Perches <joe@perches.com>
Subject: [RESEND PATCH 0/2] Make functions of dev_<level> macros, recursive vsnprintf
Date: Wed,  3 Mar 2010 22:27:21 -0800
Message-ID: <cover.1267682641.git.joe__32645.5639712096$1267684106$gmane$org@perches.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1359 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488Ab0CDG1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 01:27:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Typo'ed Linus' email address, added Greg KH and netdev)
 
dev_<level> macros use a lot of repetitive string space.

Eliminate the string prefixes and function arguments from all the macro uses
and consolidate them in functions.

This patchset saves about 60K.

This implementation also adds the ability to use a struct va_format to
emit a format string along with va_list arguments.

This %pV implementation should not be used without a wrapper that
does printf argument verification like the dev_<level> functions.

Inspired a bit by Nick Andrew's patches and Linus' comments in December 2008
http://lkml.org/lkml/2008/12/6/15
http://lkml.org/lkml/2008/12/6/101

Joe Perches (2):
  vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
  device.h drivers/base/core.c Convert dev_<level> macros to functions

 drivers/base/core.c    |  124 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/device.h |  102 +++++++++++++++++++++++++++++----------
 include/linux/kernel.h |    5 ++
 lib/vsprintf.c         |    9 ++++
 4 files changed, 214 insertions(+), 26 deletions(-)

