From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 13:55:19 +0300
Message-ID: <20071123105518.GA22062@2ka.mipt.ru>
References: <4745DCD7.8070805@simon.arlott.org.uk> <20071123002157.cb27f4a1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Matt Mackall <mpm@selenic.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33574 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770AbXKWLB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 06:01:56 -0500
Content-Disposition: inline
In-Reply-To: <20071123002157.cb27f4a1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 12:21:57AM -0800, Andrew Morton (akpm@linux-foundation.org) wrote:
> > [2059664.615816] __iptables__: init4 IN=ppp0 OUT=ppp0 WARNING: at kernel/softirq.c:139 local_bh_enable()
> > [2059664.620535]  [<80120364>] local_bh_enable+0x3c/0x97

> > [2059664.620657]  [<8011c205>] __call_console_drivers+0x61/0x6d
> > [2059664.620669]  [<8011c3fc>] release_console_sem+0x164/0x1bf
> > [2059664.620679]  [<8011c81f>] vprintk+0x27a/0x2ff
 
> If that trace is to be beieved we're doing nefilter stuff on packets which
> were sent across netconsole.
> 
> This probably isn't anything the netfilter guys have thought about.  And
> probably we don't want them to.  Is there some simple way in which we can
> exempt netconsole from netfilter processing?

This is not about netfilter, but about freeing skb in interrupt context, 
which is not allowed, and in interrupt skbs are queued to be freed in softirq,
but netcnsole wants to flush softirq freeing queue. That is a question: why?

Removing zap_completion_queue() from find_skb() will fix the warning,
but I'm not sure this is a correct fix. I've added Matt to the Cc list.

-- 
	Evgeniy Polyakov
