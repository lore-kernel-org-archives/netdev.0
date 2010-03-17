From: Chase Douglas <chase.douglas@canonical.com>
Subject: Re: [PATCH 1/1] 3c59x: Acquire vortex lock instead of disabling irq
Date: Wed, 17 Mar 2010 14:20:45 -0400
Message-ID: <40ec3ea41003171120x26d2e8b4q6b59c992ab28e454@mail.gmail.com>
References: <1268836396-23943-1-git-send-email-chase.douglas@canonical.com>
	 <1268836396-23943-2-git-send-email-chase.douglas@canonical.com>
	 <20100317.110320.15445884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:40659 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab0CQSUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 14:20:45 -0400
Received: by pwi1 with SMTP id 1so1022316pwi.19
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 11:20:45 -0700 (PDT)
In-Reply-To: <20100317.110320.15445884.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 2:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Chase Douglas <chase.douglas@canonical.com>
> Date: Wed, 17 Mar 2010 10:33:16 -0400
>
>> Last year, threaded IRQ handlers were introduced to the mainline kernel.
>> This change requires the disable_irq function to sleep if any IRQ
>> handler threads for a given IRQ line are running.
>>
>> Back in 2006, while working on the -rt patch set that had threaded IRQ
>> handlers, the vortex_timer function was causing scheduling bugs because
>> it is run in softirq context and called disable_irq. This patch was the
>> best fix determined at the time, and still exists in the .33 -rt
>> patchset. Now that threaded IRQ handlers are present in the mainline
>> kernel we need to apply the patch there as well.
>>
>> http://lkml.org/lkml/2006/5/12/178
>>
>> BugLink: http://bugs.launchpad.net/bugs/533335
>>
>> Signed-off-by: Chase Douglas <chase.douglas@canonical.com>
>
> This code is very much intentionally using disable_irq*().
>
> The operation being performed here is extremely expensive,
> and during that time if we have cpu interrupts disabled
> serial devices will drop characters etc.

If that's the case, what's the solution? It's not safe to call
disable_irq* in softirq context anymore. With the patch we have a
stable driver that may cause some serial devices to drop characters.
Without the patch we have an unstable driver that can lock up. To me
it seems the latter is preferable to the former, especially when the
lockup is occurs somewhat frequently.

-- Chase
