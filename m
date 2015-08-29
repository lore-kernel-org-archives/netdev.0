From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Fri, 28 Aug 2015 17:59:51 -0700
Message-ID: <1440809991.8932.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <20150827.113823.214019265460582055.davem@davemloft.net>
	 <55E00238.10909@linux.vnet.ibm.com>
	 <20150828.112413.424099339331017970.davem@davemloft.net>
	 <1440789654.11525.137.camel@perches.com>
	 <1440794020.8932.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440795211.11525.146.camel@perches.com>
	 <1440795336.8932.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440796183.11525.153.camel@perches.com>
	 <1440796487.8932.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440797172.11525.161.camel@perches.com>
	 <1440800980.8932.66.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440803577.11525.182.camel@perches.com>
	 <1440806774.8932.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440808524.11525.189.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	raghavendra.kt@linux.vnet.ibm.com, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35071 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbH2A7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 20:59:54 -0400
In-Reply-To: <1440808524.11525.189.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-28 at 17:35 -0700, Joe Perches wrote:

> That of course depends on what a "leaf" is and
> whether or not any other function call in the
> "leaf" consumes stack.
> 
> inet6_fill_ifla6_attrs does call other functions
> (none of which has the stack frame size of k.alloc)

Just define/use this automatic array in the damn leaf function.

That should not be hard, and maybe no one will complain and we can
work on more complex issues.
