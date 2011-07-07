From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] x86: Implement strict user copy checks for x86_64
Date: Thu, 7 Jul 2011 14:54:13 -0700
Message-ID: <20110707145413.90578915.akpm@linux-foundation.org>
References: <1306865673-20560-1-git-send-email-sboyd@codeaurora.org>
	<1306865673-20560-4-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52352 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751763Ab1GGVyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 17:54:15 -0400
In-Reply-To: <1306865673-20560-4-git-send-email-sboyd@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 May 2011 11:14:32 -0700
Stephen Boyd <sboyd@codeaurora.org> wrote:

> Strict user copy checks are only really supported on x86_32 even
> though the config option is selectable on x86_64. Add the
> necessary support to the 64 bit code to trigger copy_from_user()
> warnings at compile time.

I'm still reluctant to go and throw a pile of warnings into many
people's faces without having made an attempt to fix them.


We get a screen full of these:

    inlined from 'pktgen_if_write' at net/core/pktgen.c:877:
/usr/src/devel/arch/x86/include/asm/uaccess_64.h:64: warning: call to 'copy_from_user_overflow' declared with attribute warning: copy_from_user() buffer size is not provably correct
In function 'copy_from_user',
    inlined from 'pktgen_if_write' at net/core/pktgen.c:1145:
/usr/src/devel/arch/x86/include/asm/uaccess_64.h:64: warning: call to 'copy_from_user_overflow' declared with attribute warning: copy_from_user() buffer size is not provably correct
In function 'copy_from_user',
...

and I don't immediately see a way of suppressing them without adding
additional code.

Ideas?
