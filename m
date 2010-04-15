From: David Miller <davem@davemloft.net>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 00:57:26 -0700 (PDT)
Message-ID: <20100415.005726.205428265.davem@davemloft.net>
References: <l2p412e6f7f1004150030o8a406133s91d6614cbb106796@mail.gmail.com>
	<20100415.003711.159334670.davem@davemloft.net>
	<u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752342Ab0DOH5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 03:57:23 -0400
In-Reply-To: <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 15 Apr 2010 15:47:26 +0800

> On Thu, Apr 15, 2010 at 3:37 PM, David Miller <davem@davemloft.net> wrote:
>> From: Changli Gao <xiaosuo@gmail.com>
>> Date: Thu, 15 Apr 2010 15:30:44 +0800
>>
>>> Should netif_rx() be used only when preemption is disabled? If not,
>>> netif_rx_ni() should be used instead.?
>>
>> netif_rx() must be invoked from a hardware or software interrupt,
>> which implies preemption disabled.
>>
>> In netif_rx_ni(), the "ni" means "not interrupt".
>>
> 
> yea, I know netif_rx_ni()'s meaning. It means that the following
> changes aren't necessary.
> 
>  #else
> -       cpu = smp_processor_id();
> +       ret = enqueue_to_backlog(skb, get_cpu());
> +       put_cpu();
> 

Why?  If we are in an interrupt (either soft or hard) then
smp_processor_id() is stable, and valid.

Changli, I find it very frustrating to communicate with you, you are
very terse in your descriptions and analysis and you make many simple
errors that would be avoided if you spent more time thinking about
things before sending your emails. :-/

Instead of just showing some pseudo patch, state WHY it is needed.
Talk about the execution state of environment and what rules or other
things are being violated which must be corrected.
