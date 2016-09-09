From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [1/2] carl9170: Fix wrong completion usage
Date: Fri, 9 Sep 2016 14:16:17 +0200
Message-ID: <a4ae46314f69459ba45600306e933108@euamsexm01a.eu.qualcomm.com>
References: <1471525926-20384-2-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Christian Lamparter <chunkeey@googlemail.com>,
        "Luis R . Rodriguez" <mcgrof@kernel.org>,
        <ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Daniel Wagner <daniel.wagner@bmw-carit.de>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:45843 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750980AbcIIMQ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 08:16:26 -0400
In-Reply-To: <1471525926-20384-2-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Wagner <wagi@monom.org> wrote:
> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
> 
> carl9170_usb_stop() is used from several places to flush and cleanup any
> pending work. The normal pattern is to send a request and wait for the
> irq handler to call complete(). The completion is not reinitialized
> during normal operation and as the old comment indicates it is important
> to keep calls to wait_for_completion_timeout() and complete() balanced.
> 
> Calling complete_all() brings this equilibirum out of balance and needs
> to be fixed by a reinit_completion(). But that opens a small race
> window. It is possible that the sequence of complete_all(),
> reinit_completion() is faster than the wait_for_completion_timeout() can
> do its work. The wake up is not lost but the done counter test is after
> reinit_completion() has been executed. The only reason we don't see
> carl9170_exec_cmd() hang forever is we use the timeout version of
> wait_for_copletion().
> 
> Let's fix this by reinitializing the completion (that is just setting
> done counter to 0) just before we send out an request. Now,
> carl9170_usb_stop() can be sure a complete() call is enough to make
> progess since there is only one waiter at max. This is a common pattern
> also seen in various drivers which use completion.
> 
> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>

Thanks, 1 patch applied to ath-next branch of ath.git:

78a9e170388b carl9170: Fix wrong completion usage

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9287819/
