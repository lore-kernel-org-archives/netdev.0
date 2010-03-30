From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: XT_ALIGN changed to use ALIGN breaks iproute2
Date: Tue, 30 Mar 2010 16:15:48 +0300
Message-ID: <b6fcc0a1003300615k54092120nfb8b5378771657@mail.gmail.com>
References: <20100330092829.GA3106@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:55158 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab0C3NPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 09:15:49 -0400
Received: by pwi5 with SMTP id 5so7677916pwi.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 06:15:49 -0700 (PDT)
In-Reply-To: <20100330092829.GA3106@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 12:28 PM, Andreas Henriksson <andreas@fatal.se> wrote:
> You updated the kernel header include/linux/netfilter/x_tables.h
> in torvalds/linux-2.6.git commit 42107f5009da223daa800d6da6904d77297ae829
> with the comment "Use ALIGN() macro while I'm at it for same types.".
>
> When this header was synced into iproute2 the build broke because the
> ALIGN macro apparently only is defined in kernel headers.
>
> (For iproute2 the problem was introduced in
> 8ecdcce08319d0e39b0d32c1d17db3f69d85a35c and found by Stephen
> and worked around in 609ceb807deba8e23 and edaaa11e5a3cf2c9c1a39)
>
> I'm guessing the problem in the iproute2 header sync is just a heads
> up for what's going to happen when distributions updates their
> system headers to match linux 2.6.33.
>
>
> Could someone who knows how the userspace version of the kernel
> headers are generated please find a suitable solution?

We can export ALIGN to userspace, but the name is so generic,
so it's not clear what breakage more risky.

XT_ALIGN is a macro so breakage will appear only when it's used,
not when header is included directly or indirectly.

We have tc, iptables, both carry their own copy of headers, what else?

Right now, I'd say, do nothing, and iptables will carry fixlet as in tc,
eventually.
