From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v6_repost 2/3] net: core: add SW stats to
 if_stats_msg
Date: Tue, 23 Aug 2016 09:26:51 +0200
Message-ID: <20160823072651.GB1975@nanopsycho>
References: <1471612650-4508-3-git-send-email-jiri@resnulli.us>
 <57BBE47D.3060805@cumulusnetworks.com>
 <20160823065318.GA1975@nanopsycho>
 <20160823.000415.624700756560666111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
        nogahf@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, ogerlitz@mellanox.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
        eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37168 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbcHWH1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 03:27:36 -0400
Received: by mail-wm0-f53.google.com with SMTP id i5so180283794wmg.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 00:26:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160823.000415.624700756560666111.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 23, 2016 at 09:04:15AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Tue, 23 Aug 2016 08:53:18 +0200
>
>> Anyway I think that next level of nesting is not necessary. On
>> contrary, it is wrong. The current level is extensible, mixed and
>> flagged already. I don't see any reason why not to add whatever kind of
>> stats here. What makes IFLA_STATS_LINK_SW_64 or for example
>> IFLA_STATS_LINK_HW_ACL so special it has to be nested in some other
>> attr? I would understand it it would be values of one family, but that
>> is not the case.
>
>First, I agree with Roopa.  If we want to put this stuff out
>there is should be bucketed together in a nested attribute with
>other similar stats specifications.

Well I still don't think that IFLA_STATS_LINK_SW_64 and
IFLA_STATS_LINK_HW_ACL are related. You cannot put it under *DRIVER*
nest as IFLA_STATS_LINK_SW_64 are core stats. So we can put them under
*MISC* nest attr. But that is exactly purpose of the top-level here.
/me confused


>
>Second, the more I think about this what you're providing isn't
>actually a new statistic type.
>
>It's a filter.
>
>So why don't we just provide a filter specification that gets passed
>down into the driver.  And the user can ask for "SW stats" or whatever
>using that.

for this particular stats (sw stats) you can look at it that way. The
question is that in case we handle it the filter way instead of
multiattr way. Is it convenient for user to do 2 netlink calls instead
of one? I tend to like the one-call-flag-what-you-want approach better.
