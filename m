From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Sat, 06 Sep 2014 09:38:27 -0700
Message-ID: <1410021507.11872.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ED4354.9090904@intel.com>
	 <20140814.162024.2218312002979492106.davem@davemloft.net>
	 <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
	 <20140821.162406.2076033247433267586.davem@davemloft.net>
	 <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410018384.11872.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:42270 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaIFQi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 12:38:29 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so23894097pab.8
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 09:38:29 -0700 (PDT)
In-Reply-To: <1410018384.11872.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-06 at 08:46 -0700, Eric Dumazet wrote:

> Works fine on IPv4, not on IPv6, I will submit a v2 (with a proper title
> btw)

Oh well, we first need to fix IPv6 early demux.

Current net-next kernel profile

+  20.95%      netserver  [kernel.kallsyms]    [k] dst_release     
+  19.33%      netserver  [kernel.kallsyms]    [k] ip6_pol_route.isra.46
+  11.75%      netserver  [kernel.kallsyms]    [k] inet6_sk_rx_dst_set
+   3.72%      netserver  [kernel.kallsyms]    [k] ip6_input_finish

So we repeat over and over calls to inet6_sk_rx_dst_set(),
something is surely wrong.
