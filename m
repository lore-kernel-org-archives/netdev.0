From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH v3] net, wireless: overwrite default_ethtool_ops
Date: Mon, 21 Jan 2013 12:52:43 -0800
Message-ID: <CAB=NE6XjvupJ5XO0EN0HVwdy61ECWL=Ey0g1gsNm+v8Sen=nsQ@mail.gmail.com>
References: <20130111091909.GA2347@redhat.com> <1357934432.2643.4.camel@bwh-desktop.uk.solarflarecom.com>
 <20130111.155936.1799008114956712424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	edumazet@google.com, greearb@candelatech.com, bjorn@mork.no,
	linux-wireless@vger.kernel.org, mirqus@gmail.com,
	johannes@sipsolutions.net, David Miller <davem@davemloft.net>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:65320 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab3AUUxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 15:53:05 -0500
In-Reply-To: <20130111.155936.1799008114956712424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 3:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 11 Jan 2013 20:00:32 +0000
>
>> On Fri, 2013-01-11 at 10:19 +0100, Stanislaw Gruszka wrote:
>>> Since:
>>>
>>> commit 2c60db037034d27f8c636403355d52872da92f81
>>> Author: Eric Dumazet <edumazet@google.com>
>>> Date:   Sun Sep 16 09:17:26 2012 +0000
>>>
>>>     net: provide a default dev->ethtool_ops
>>>
>>> wireless core does not correctly assign ethtool_ops.
>>>
>>> After alloc_netdev*() call, some cfg80211 drivers provide they own
>>> ethtool_ops, but some do not. For them, wireless core provide generic
>>> cfg80211_ethtool_ops, which is assigned in NETDEV_REGISTER notify call:
>>>
>>>         if (!dev->ethtool_ops)
>>>                 dev->ethtool_ops = &cfg80211_ethtool_ops;
>>>
>>> But after Eric's commit, dev->ethtool_ops is no longer NULL (on cfg80211
>>> drivers without custom ethtool_ops), but points to &default_ethtool_ops.
>>>
>>> In order to fix the problem, provide function which will overwrite
>>> default_ethtool_ops and use it by wireless core.
>>>
>>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>> [...]
>>
>> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
>
> Applied.

Stanislaw, I see Eric's patch went in on v3.7-rc1 as such I suspect
this needs to be submitted as a stable fix for v3.7.5. Its already on
v3.8-rc4.

mcgrof@frijol ~/linux-stable (git::linux-3.7.y)$ git describe
--contains 2c60db037034d27f8c636403355d52872da92f81
v3.7-rc1~145^2~142

  Luis
