From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH RFC 0/4] ARM/KGDB: Some fixes for SMP machines
Date: Wed, 7 Jul 2010 21:12:22 +0400
Message-ID: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wessel <jason.wessel@windriver.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: kgdb-bugreport@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52544 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016Ab0GGRM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 13:12:27 -0400
Received: by wyf23 with SMTP id 23so3417735wyf.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 10:12:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

It appears that KGDB can easily hang SMP ARM machines.

Here are few fixes that I come up with.

Before the patches, doing 'b schedule' and then 1-3 'continue'
or 'si' gdb commands would cause the board to lock-up completely.

After the patches, KGDB seems to be bullet proof. Well, at least
with the 'b schedule' testcase, there might be other bugs which
I didn't hit yet. ;-)

Notes:

1. I'm testing with I/D caches disabled. With enabled caches,
   ARMv6K still locks-up. I'll test ARMv7 soon, and will try
   to debug cache issues on ARMv6K.

2. The patches are against a heavily patched kernel, and so far
   I didn't rebase them onto the 'debug core' rework as found
   in the very latest mainline kernels. I'll rebase the patches
   soon, so for now this is just an RFC.

Thanks!

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
