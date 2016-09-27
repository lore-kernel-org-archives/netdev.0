From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH v4 4/7] ipv6 addrconf: add new sysctl 'router_solicitation_max_interval'
Date: Tue, 27 Sep 2016 11:30:50 +0900
Message-ID: <CANP3RGfNGgw9H5Hsn7sgadHu5+kBcGfhY6Y_iTKNEjoL9gL7xg@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-5-git-send-email-zenczykowski@gmail.com>
 <87d7f248-4d95-4253-78ae-6dd110db6330@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:36538 "EHLO
        mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752793AbcI0CbI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 22:31:08 -0400
Received: by mail-yw0-f176.google.com with SMTP id t67so264115ywg.3
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 19:31:07 -0700 (PDT)
In-Reply-To: <87d7f248-4d95-4253-78ae-6dd110db6330@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Is seconds granular enough?

The only reason why one would ever want to go into fractions of
seconds would be some sort of unittesting with very low delays.

In any normal environment the max is going to be tens if not hundreds
or thousands of seconds.

Also note that the delay and interval (ie. not max interval) are also
currently exported in seconds, so having more granularity for
max_seconds is kind of pointless.

I have been considering whether I could make proc_dointvec_jiffies
accept floating point input (and output) though... although that seems
a little harder and probably out of scope of this change.
