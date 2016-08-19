From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 0/1] HW checksum offload problem on Xilinx Zynq GEM
Date: Fri, 19 Aug 2016 13:00:33 -0700
Message-ID: <CALx6S37DD+Nq8PzvJLrF1Fmv+GLW9v-vPc-+LrganhbFsovwCA@mail.gmail.com>
References: <1471611898-3852-1-git-send-email-helmut.buchsbaum@gmail.com> <20160819.122839.1847374426262584384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: helmut.buchsbaum@gmail.com, nicolas.ferre@atmel.com,
        michal.simek@xilinx.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        cyrille.pitchen@atmel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:36380 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbcHSUAe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 16:00:34 -0400
Received: by mail-it0-f43.google.com with SMTP id e63so38010634ith.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 13:00:34 -0700 (PDT)
In-Reply-To: <20160819.122839.1847374426262584384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 12:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
> Date: Fri, 19 Aug 2016 15:04:57 +0200
>
>> When working on upgrading the v3.x kernels of our embedded devices
>> to more recent 4.x kernels we noticed some of our proprietary networking
>> stuff is broken. Further investigations brought up an issue with small
>> UDP packets (data payload <= 2), which contained wrong UDP header
>> checksums.
>> We tracked this down to commit 85ff3d87bf2ef1fadcde8553628c60f79806fdb4
>> net/macb: add TX checksum offload feature. It turns out that Zynq's GEM
>> is obviously buggy regarding the UDP checksum calculation of such small
>> UDP packets as long as the UDP checksum field is != 0 *BEFORE* the
>> HW calulation. But since udp_send_skb() *ALWAYS* calculates the UDP header
>> checksum (unless disabled via socket option), this is the usual case.
>> Unfortunately it does not respect the net device feature setting which
>> would leave UDP checksum untouched when checksum offloading is enabled.
>
> Then simply clear the checksum field in the driver, or fix
> udp_send_skb() to do what you claim it is supposed to.
>
> That seems like a much more appropriate fix to me.

Fix the driver to do that. When offloading a UDP checksum the pseudo
header checksum is written into the checksum field-- that's the
interface that everyone else has been using without issue.
