From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: pull-request: wireless-drivers-next 2015-01-22
Date: Thu, 22 Jan 2015 14:31:53 +0200
Message-ID: <8761bznghy.fsf@kamboji.qca.qualcomm.com>
References: <87h9vjnic4.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:3369 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbbAVMcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:32:02 -0500
In-Reply-To: <87h9vjnic4.fsf@kamboji.qca.qualcomm.com> (Kalle Valo's message
	of "Thu, 22 Jan 2015 13:52:11 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kalle Valo <kvalo@codeaurora.org> writes:

> Hi Dave,
>
> now a bigger pull request for net-next. Rafal found a UTF-8 bug in
> patchwork[1] and because of that two commits (d0c102f70aec and
> d0f66df5392a) have his name corrupted:
>
>     Acked-by: Rafa? Mi?ecki <zajec5@gmail.com>
>
> Somehow I failed to spot that when I commited the patches. As rebasing
> public git trees is bad, I thought we can live with these and decided
> not to rebase. But I'll pay close attention to this in the future to
> make sure that it won't happen again. Also we requested an update to
> patchwork.kernel.org, the latest patchwork doesn't seem to have this
> bug.
>
> Also please note this pull request also adds one DT binding doc, but
> this was reviewed in the device tree list:
>
>  .../bindings/net/wireless/qcom,ath10k.txt          |   30 +
>
> Please let me know if you have any issues.

I almost missed that there's actually a small conflict with net-next:

CONFLICT (content): Merge conflict in drivers/net/wireless/ath/wil6210/cfg80211.c

Please fix it like this in wil_cid_fill_sinfo():

	if (test_bit(wil_status_fwconnected, wil->status)) {
		sinfo->filled |= BIT(NL80211_STA_INFO_SIGNAL);
		sinfo->signal = reply.evt.sqi;
	}

-- 
Kalle Valo
