From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] make per interface sysctl entries configurable
Date: Mon, 26 Oct 2009 17:24:58 +0200
Message-ID: <200910261724.58541.denys@visp.net.lb>
References: <200910251954.49700.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34973 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbZJZPY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 11:24:56 -0400
In-Reply-To: <200910251954.49700.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I test it on pppoe with 1k customers. It works flawlessly.

When there is problem on network and i have massive users disconnect and then 
login, the bottleneck is in lock somewhere in creation of sysctl(according 
perf). PPPoE after 200-300 interfaces will start dying, and connection rate 
will drop to 20-50 customers per minute, load average will jump to 70-100 (i 
guess pppd processes waiting their turn). With this patch i am able to 
sustain 200-300 customers / minute login rate and perftop is "clear" now.

Definitely this option is optional, and doesn't cut any functionality by 
default, just giving more choice. And for PPP (pppoe/pptp) NAS it is very 
useful.

On Sunday 25 October 2009 19:54:49 Octavian Purdila wrote:
> RFC patches are attached.
>
> Another possible approach: add an interface flag and use it to decide
> whether we want per interface sysctl entries or not.
>
> Benchmarks for creating 1000 interface (with the ndst module previously
> posted on the list, ppc750 @800Mhz machine):
>
> - without the patches:
>
> real    4m 38.27s
> user    0m 0.00s
> sys     2m 18.90s
>
> - with the patches:
>
> real    0m 0.10s
> user    0m 0.00s
> sys     0m 0.05s
>
> Thanks,
> tavi


