From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: cpsw at high broadcast load
Date: Tue, 5 Apr 2016 10:19:11 +0200
Message-ID: <CAGm1_kuRqeLtszMNJGotjaruiF-Ln8HJK2u24wXVin-VMMZyxQ@mail.gmail.com>
References: <CAGm1_ks6b4-bvk6x1GyRNVo-_NYRStEESuG0HFAA=zEH2OUCSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Felipe Balbi <balbi@ti.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:34061 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757406AbcDEITc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:19:32 -0400
Received: by mail-vk0-f51.google.com with SMTP id e185so8362045vkb.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 01:19:31 -0700 (PDT)
In-Reply-To: <CAGm1_ks6b4-bvk6x1GyRNVo-_NYRStEESuG0HFAA=zEH2OUCSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mugunthan,

On Fri, Jul 31, 2015 at 2:22 PM, Yegor Yefremov
<yegorslists@googlemail.com> wrote:
> We experience massive problems, when putting am335x based devices into
> high broadcast load environment (customer reports). To reproduce the
> issue we've written following Python script
>
> #!/usr/bin/python
> # Send UDP broadcast packets
>
> myport = 50000
>
> import sys, time
> from socket import *
>
> if len(sys.argv) == 2:
>     myport = int(sys.argv[1])
>
> s = socket(AF_INET, SOCK_DGRAM)
> s.bind(('192.168.254.36', 0))
> s.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)
>
> while 1:
>     #data = repr(time.time()) + '\n'
>     data = "a"
>     s.sendto(data, ('<broadcast>', myport))
>     time.sleep(0.0001)
>
> Just running this script on a host machine and invoking "top" on the
> am335x machine results in sirq showing about 90% for 600MHz CPU and
> 3.18.x kernel. Below example of idle "top" output for the reference:
>
> Mem: 13432K used, 217844K free, 64K shrd, 652K buff, 4956K cached
> CPU:   0% usr   0% sys   0% nic  99% idle   0% io   0% irq   0% sirq
>
> Then I tried 4.2.0-rc4 and sirq was about 80%, then I applied both
>
> drivers: net: cpsw: remove  disable_irq/enable_irq as irq can be
>     masked from cpsw itself
>   drivers: net: cpsw: add separate napi for tx packet handling for
>     performance improvment
>
> and sirq lowered to about 50%, but I have also tried evil vendor tree
> 3.2.0+ and sirq was about 2%. Am I missing some kernel option/setting?
> Any idea, how one can make am335x with a recent kernel to keep sirq as
> low as possible, when no service listens to these broadcasts?
>
> All am335x kernels used dual_emac mode.
>
> I have similar situation with am3517. Kernel 2.6.37 (latest official
> TI kernel) shows sirq 24% and upstream 4.1.2 about 90%.

Could you please look at this issue. It is still valid for 4.5 and am335x.

Thanks.

Yegor
