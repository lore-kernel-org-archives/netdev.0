From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: On Linux rate limiting and the magic value of 34.64 Gbps...
Date: Fri, 25 Mar 2011 00:14:25 -0700
Message-ID: <AANLkTi=UTcZ8Q-ULk4CAkbZztYKkDeZHK55LHVDRFH2r@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Linux NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43732 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933032Ab1CYHO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 03:14:26 -0400
Received: by wya21 with SMTP id 21so832742wya.19
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2011 00:14:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

The Linux rate limiting code relies on the rate field of struct tc_ratespec.
This field is a __u32 and measures rate in "bytes per second".

This basically means maximum representable rate is 4GB per second.
This is equivalent to 34.36 Gbps and I just ran across that limit with
40 Gbps (which behaves like 5.64 Gbps because of overflow/truncation).
Seeing as this structure is exposed to userspace for both read and
write via various netlink paths (in cbq, htb, tbf, etc...) there
doesn't seem to be a particularly clean way to increase the size of
this field.  While there is a __reserved field that could
theoretically be repurposed as some sort of rate bit shift register, I
don't think we can rely on __reserved having been set to zero by
userspace (by older programs), and we will definitely see problems
with output by programs (tc) that don't expect to have to parse this
field to output an understandable rate limit...

Anybody have any bright ideas?

Thanks,
Maciej
