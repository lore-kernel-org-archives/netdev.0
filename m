From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH v2] prism54: isl_38xx: Replace 'struct timeval'
Date: Wed, 23 Mar 2016 14:28:10 +0100
Message-ID: <3071133.ssTx2e0NSm@wuerfel>
References: <20160322221615.GA55727@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Tina Ruchandani <ruchandani.tina@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:58506 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652AbcCWN2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 09:28:18 -0400
In-Reply-To: <20160322221615.GA55727@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 March 2016 15:16:15 Tina Ruchandani wrote:
> 'struct timeval' uses a 32-bit seconds field which will overflow in
> year 2038 and beyond. This patch is part of a larger effort to remove
> all instances of 'struct timeval' from the kernel and replace them
> with 64-bit timekeeping variables.
> The correctness of the code isn't affected by this patch - the seconds
> value being printed would earlier be wrong due to overflow in timeval,
> and now it gets truncated to 32-bit due to the 'long' cast used on
> tv.sec field to prevent compiler warnings. Truly fixing this would
> require changing the debug print to print more than 8 digits and
> use a different specifier from %li.
> The patch was build-tested / debugged by removing the
> "if VERBOSE > SHOW_ERROR_MESSAGES" guards.
> 
> Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> --
> Changes in v2:
> - Changed printf specifier as suggested by Arnd Bergmann to
> avoid truncation.
> 

The patch looks great now, but it no longer matches the description,
as you actually fix the correctness.

	Arnd
