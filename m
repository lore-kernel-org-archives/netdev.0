From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [1/2] ath9k: ar9002_mac: kill off ACCESS_ONCE()
Date: Thu, 12 Jan 2017 12:00:25 +0100
Message-ID: <35e1ad24f23d41c7956d82b5ca9fc0e6@euamsexm01a.eu.qualcomm.com>
References: <1482864599-19995-2-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <ath9k-devel@qca.qualcomm.com>,
        <kvalo@codeaurora.org>, <linux-wireless@vger.kernel.org>,
        <ath9k-devel@lists.ath9k.org>, <netdev@vger.kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482864599-19995-2-git-send-email-mark.rutland@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Rutland <mark.rutland@arm.com> wrote:
> For several reasons, it is desirable to use {READ,WRITE}_ONCE() in
> preference to ACCESS_ONCE(), and new code is expected to use one of the
> former. So far, there's been no reason to change most existing uses of
> ACCESS_ONCE(), as these aren't currently harmful.
> 
> However, for some new features (e.g. KTSAN / Kernel Thread Sanitizer),
> it is necessary to instrument reads and writes separately, which is not
> possible with ACCESS_ONCE(). This distinction is critical to correct
> operation.
> 
> It's possible to transform the bulk of kernel code using the Coccinelle
> script below. However, for some files (including the ath9k ar9002 mac
> driver), this mangles the formatting. As a preparatory step, this patch
> converts the driver to use {READ,WRITE}_ONCE() without said mangling.
> 
> ----
> virtual patch
> 
> @ depends on patch @
> expression E1, E2;
> @@
> 
> - ACCESS_ONCE(E1) = E2
> + WRITE_ONCE(E1, E2)
> 
> @ depends on patch @
> expression E;
> @@
> 
> - ACCESS_ONCE(E)
> + READ_ONCE(E)
> ----
> 
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: ath9k-devel@qca.qualcomm.com
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: linux-wireless@vger.kernel.org
> Cc: ath9k-devel@lists.ath9k.org
> Cc: netdev@vger.kernel.org

2 patches applied to ath-next branch of ath.git, thanks.

d5a3a76a9cb8 ath9k: ar9002_mac: kill off ACCESS_ONCE()
50f3818196f5 ath9k: ar9003_mac: kill off ACCESS_ONCE()

-- 
https://patchwork.kernel.org/patch/9489799/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
