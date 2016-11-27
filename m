From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 0/3] update ifstat for new stats
Date: Sun, 27 Nov 2016 10:00:18 -0800
Message-ID: <583B1F32.6020005@cumulusnetworks.com>
References: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, yotamg@mellanox.com,
        jiri@mellanox.com, idosch@mellanox.com, ogerlitz@mellanox.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33554 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752187AbcK0SAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 13:00:20 -0500
Received: by mail-pg0-f51.google.com with SMTP id 3so48135271pgd.0
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 10:00:19 -0800 (PST)
In-Reply-To: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resending ...failed to send it to the list earlier)

On 11/24/16, 6:12 AM, Nogah Frankel wrote:
> Previously stats were gotten by RTM_GETLINK which return 32 bits based
> statistics. It support only one type of stats.
> Lately, a new method to get stats was added - RTM_GETSTATS. It supports
> ability to choose stats type. The basic stats were changed from 32 bits
> based to 64 bits based.
>
> This patchset change ifstat to the new method, add it the ability to
> choose an extended type of statistic, and add the extended type of SW
> stats for packets that hit cpu.
>
>


(please cc me on the GETSTATS patches)

This looks similar to the one I had submitted here: https://www.spinics.net/lists/netdev/msg375546.html <https://www.spinics.net/lists/netdev/msg375546.html>

There are a few issues with this approach.. (unless they have already been looked at by your patch series).
 This fails new ifstat on older kernels. Moving to 64bit also invalidates existing ifstats history file. 
If you follow the discussion on my patch, there is a way to move to a new history file for 64bit
stats file and still be compatible (ie create a new file for 64 bit stats).

I had started work on fixing these limitations..., but then re-thinking all other new stats in one place
in the context of the new stats api, it is better to extend ip link. This work is also in progress.
here is how we think it should be (also CCing nikolay):

ip link stats /* similar to ip -s link for completeness */
ip link xstats [igmp|lacp]  /* depending on link-type */
ip link afstats [inet|inet6|mpls] /* depending on link-family */
ip link offloadstas [cpu|..]

possible future global non-link stats with 'ip stats [tcp]' and so on.
