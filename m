From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Fwd: [linux] [PATCH] ATH6KL: "Fix the byte alignment rule to avoid
 loss of bytes in a TCP segment" (#27)
Date: Wed, 27 Feb 2013 09:19:09 -0800
Message-ID: <CA+55aFxmE+hEm53f2gjFetNREW6J8X1GfpzeVxhHnECC-h6D7Q@mail.gmail.com>
References: <torvalds/linux/pull/27@github.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Myoungje Kim <mjei78@gmail.com>
To: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f171.google.com ([209.85.128.171]:49666 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab3B0RTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 12:19:10 -0500
Received: by mail-ve0-f171.google.com with SMTP id b10so846401vea.30
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 09:19:09 -0800 (PST)
In-Reply-To: <torvalds/linux/pull/27@github.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"How do I hate GitHub pull requests? Let me count the ways...."

That said, the bug description alone makes this worth forwarding,
despite the cluelessness of GitHub pull requests. Myoungje Kim spent
some time explaining the issue, so while I despise the github pull
request format, I'm not faulting the effort spent on describing the
patch.

                  Linus

---------- Forwarded message ----------
From: Steven Kim <notifications@github.com>
Date: Tue, Feb 26, 2013 at 9:17 PM
Subject: [linux] [PATCH] ATH6KL: "Fix the byte alignment rule to avoid
loss of bytes in a TCP segment" (#27)
To: torvalds/linux <linux@noreply.github.com>


I found the driver bug which occur loss of some bytes on the TCP/IP stack.

Either first 3 bytes of the first received tcp segment or last one
over MTU size file can be loss due to the byte alignment problem.
Although ATH6KL_HTC_ALIGN_BYTES was defined
for 'extra bytes for htc header alignment'
in the patch "Fix buffer alignment for scatter-gather I/O"(1df94a8),
there exists the bytes loss issue which means that it will be truncated
3 bytes in the transmitted file contents if a file which
has over MTU size is transferred through TCP/IP stack.
It doesn't look like TCP/IP stack bug of 3.5 or the latest version of
kernel but the byte alignment issue.
This patch is to use the roundup() function for the byte alignment
rather than the predefined ATH6KL_HTC_ALIGN_BYTES.

Signed-off-by: Myoungje Kim mjei78@gmail.com

________________________________

You can merge this Pull Request by running

  git pull https://github.com/kingpotato/linux master

Or view, comment on, or merge it at:

  https://github.com/torvalds/linux/pull/27

Commit Summary

ath6kl: Fix the byte alignment rule to avoid loss of bytes in a TCP segment

File Changes

M drivers/net/wireless/ath/ath6kl/init.c (4)
M drivers/net/wireless/ath/ath6kl/main.c (4)

Patch Links:

https://github.com/torvalds/linux/pull/27.patch
https://github.com/torvalds/linux/pull/27.diff
