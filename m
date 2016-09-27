From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH v4 4/7] ipv6 addrconf: add new sysctl 'router_solicitation_max_interval'
Date: Tue, 27 Sep 2016 19:08:44 +0900
Message-ID: <CANP3RGfOXN59CiSpPj-BfGuYDguDOqL95_tDxDOB4=4sfuR94Q@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-5-git-send-email-zenczykowski@gmail.com>
 <87d7f248-4d95-4253-78ae-6dd110db6330@stressinduktion.org>
 <CANP3RGfNGgw9H5Hsn7sgadHu5+kBcGfhY6Y_iTKNEjoL9gL7xg@mail.gmail.com> <8e332a23-5653-1e70-7c74-e7bcbbe0884a@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:36703 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753111AbcI0KIp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 06:08:45 -0400
Received: by mail-yw0-f179.google.com with SMTP id t67so5037188ywg.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 03:08:45 -0700 (PDT)
In-Reply-To: <8e332a23-5653-1e70-7c74-e7bcbbe0884a@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Good point. Using ms should actually be easy, instead of
> proc_dointvec_jiffies you can use proc_dointvec_ms_jiffies.

Yes, I'm aware of this, but 'proc_dointvec_ms_jiffies' seems to be a
bit of a hack, and especially for large settings like this exporting
them to userspace in units of ms instead of seconds seems to impose
unnecessary cognitive burden on the user.

(furthermore the other two related settings are exported as seconds)

> It seems good practice to add a _ms then to the sysctl, too.

If we wanted to do that, we'd have to add _ms versions of
router_solicitation_{delay,interval}.
This seems like pointless duplication - since we can't actually delete
the older seconds one.

There isn't really any real world scenario I can think of (besides
unit-testing) where ms granularity would be useful.

If we were to actually fix proc_dointvec_jiffies to accept fractional
seconds, we'd fix all of these interfaces in one fell swoop...

I took a look at what this would take, and there doesn't really appear
to be a nice way to do it :-(
The lower level conversion functions get a character buffer and
convert it to/from an int (or maybe long).

We'd either need to switch these over to take a void* or add an
entirely separate implementation of proc_dointvec_jiffies...

(at which point it could probably also parse units (ns, us, ms, s, m,
h, d) on input if we wanted to...)

> I am fine with both ways.

I'm going to leave this as is (especially since I send out v5 before I
saw your comment)
