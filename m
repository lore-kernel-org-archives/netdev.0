From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net] bnx2x: limit fw delay in kdump to 5s after boot
Date: Thu, 07 May 2015 23:19:57 +0200
Message-ID: <554BD6FD.80308@redhat.com>
References: <1431023830-445-1-git-send-email-mschmidt@redhat.com> <B5657A6538887040AD3A81F1008BEC63D7C945@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbbEGVTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 17:19:31 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63D7C945@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 7.5.2015 v 21:03 Yuval Mintz napsal(a):
>> +       if (is_kdump_kernel()) {
>> +               ktime_t now = ktime_get_boottime();
>> +               ktime_t fw_ready_time = ktime_set(5, 0);
>> +
>> +               if (ktime_before(now, fw_ready_time))
>> +                       msleep(ktime_ms_delta(fw_ready_time, now));
>
> Can't really say I'm familiar with these APIs , but what about the lower
> msleep limit (is 20 or 50 milliseconds today?)?
> Shouldn't there be an msleep variant that's good for such cases?
> [Or is it a non-issue, since at most msleep will be inaccurate]

msleep(<small_number>) may sleep for a couple of jiffies more than one 
would expect. I think that's what you mean by "the lower msleep limit". 
It does not matter. It's not like we have to hit the 5 seconds mark exactly.

> Regardless, the patch itself looks good.

Thanks,
Michal
