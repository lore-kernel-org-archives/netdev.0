From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Thu, 24 Jan 2013 17:34:24 -0800
Message-ID: <1359077664.12374.2887.camel@edumazet-glaptop>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
	 <1359070199.12374.2557.camel@edumazet-glaptop>
	 <CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:32848 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065Ab3AYBe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 20:34:27 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so4514320dak.2
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 17:34:26 -0800 (PST)
In-Reply-To: <CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 16:14 -0800, Pravin Shelar wrote:

> I think this patch does fix csum issue without causing any performance
> regression. So this patch shld be enough to solve GRE-GSO issue. Once
> you have fix, this code can be optimized even more.

It adds the extra copy, since you assume no SG capability so
skb_segment() _does_ a copy.

As the checksum is needed, its true the copy is almost not noticed,
but one day NIC will be able to perform the checksum for us.
(Maybe its already the case for some of them)

I would first fix the checksum issue in a generic way, then
apply this patch on top of the fix, so that we can use SG and avoid
the extra copy for the typical tcp_sendmsg()

It seems you focus on the TAP use case only, seeing you removed
code that doesn't work for TAP but do work for regular locally
terminated flows.

You did a lot of implementation choices and none of them
are described in a changelog, making future work a bit hard.
