From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: limit fw delay in kdump to 5s after boot
Date: Thu, 7 May 2015 19:03:07 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63D7C945@AVMB1.qlogic.org>
References: <1431023830-445-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: Michal Schmidt <mschmidt@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41315 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751848AbbEGTDL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 15:03:11 -0400
In-Reply-To: <1431023830-445-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +       if (is_kdump_kernel()) {
> +               ktime_t now = ktime_get_boottime();
> +               ktime_t fw_ready_time = ktime_set(5, 0);
> +
> +               if (ktime_before(now, fw_ready_time))
> +                       msleep(ktime_ms_delta(fw_ready_time, now));

Can't really say I'm familiar with these APIs , but what about the lower
msleep limit (is 20 or 50 milliseconds today?)?
Shouldn't there be an msleep variant that's good for such cases?
[Or is it a non-issue, since at most msleep will be inaccurate]

Regardless, the patch itself looks good.

> +       }