From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: do not use this_cpu_ptr() in preemptible
 context
Date: Mon, 22 Sep 2014 10:28:21 -0700
Message-ID: <1411406901.26859.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140922090242.5ef15c83@urahara>
	 <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411406513.26859.136.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>, joe9mail@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:40622 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224AbaIVR2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 13:28:25 -0400
Received: by mail-pa0-f45.google.com with SMTP id lj1so4426209pab.18
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 10:28:25 -0700 (PDT)
In-Reply-To: <1411406513.26859.136.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-22 at 10:21 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> this_cpu_ptr() in preemptible context is generally bad
> 
> Sep 22 05:05:55 br kernel: [   94.608310] BUG: using smp_processor_id() in
> preemptible [00000000] code: ip/2261
> Sep 22 05:05:55 br kernel: [   94.608316] caller is
> tunnel_dst_set.isra.28+0x20/0x60 [ip_tunnel]
> Sep 22 05:05:55 br kernel: [   94.608319] CPU: 3 PID: 2261 Comm: ip Not tainted
> 3.17.0-rc5 #82
> 
> We can simply use __this_cpu_ptr(), as preemption is safe in these contexts.
> 
> Should fix https://bugzilla.kernel.org/show_bug.cgi?id=84991
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Joe <joe9mail@gmail.com>
> Fixes: 9a4aa9af447f ("ipv4: Use percpu Cache route in IP tunnels")
> ---

Hmm, I just saw raw_cpu_ptr() should be used.

I'll send a v2
