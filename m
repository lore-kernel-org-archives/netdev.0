From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
	avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 15:47:26 +0800
Message-ID: <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
References: <1271142857.16881.193.camel@edumazet-laptop> <20100415.001446.244372815.davem@davemloft.net>
	<l2p412e6f7f1004150030o8a406133s91d6614cbb106796@mail.gmail.com>
	<20100415.003711.159334670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56180 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756173Ab0DOHrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 03:47:46 -0400
Received: by gyg13 with SMTP id 13so601759gyg.19
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 00:47:46 -0700 (PDT)
In-Reply-To: <20100415.003711.159334670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 3:37 PM, David Miller <davem@davemloft.net> wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Thu, 15 Apr 2010 15:30:44 +0800
>
>> Should netif_rx() be used only when preemption is disabled? If not,
>> netif_rx_ni() should be used instead.?
>
> netif_rx() must be invoked from a hardware or software interrupt,
> which implies preemption disabled.
>
> In netif_rx_ni(), the "ni" means "not interrupt".
>

yea, I know netif_rx_ni()'s meaning. It means that the following
changes aren't necessary.

 #else
-       cpu = smp_processor_id();
+       ret = enqueue_to_backlog(skb, get_cpu());
+       put_cpu();

ret = enqueue_to_backlog(skb, smp_processor_id()); should be OK.

 #endif
-
-       return enqueue_to_backlog(skb, cpu);
+       return ret;
 }
