From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] build: unbreak linkage of m_xt.so
Date: Sun, 16 Dec 2012 18:43:03 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212161841070.27614@nerf07.vanv.qr>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr> <1355617968-26138-1-git-send-email-jengelh@inai.de> <50CDA2DA.3060805@mojatatu.com> <50CDFEFB.2070208@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: stephen.hemminger@vyatta.com, vapier@gentoo.org,
	netdev@vger.kernel.org, urykhy@gmail.com, shemonc@gmail.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:37018 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595Ab2LPRnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 12:43:05 -0500
In-Reply-To: <50CDFEFB.2070208@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 2012-12-16 18:03, Jamal Hadi Salim wrote:

> On 12-12-16 05:30 AM, Jamal Hadi Salim wrote:
>
>> I can confirm it builds fine for me now if i take out the hack I had and
>> use this patch.
>
>
> Sorry, I take what i said back and went back to explicitly adding -l xtables.
> The problem is still the intepretation of tc/Makefile. Here's the compile
> output.
> ----
> gcc -Wall -Wstrict-prototypes -O2 -I../include -DRESOLVE_HOSTNAMES
> -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -DCONFIG_GACT
> -DCONFIG_GACT_PROB -DIPT_LIB_DIR=\"/lib/xtables\" -DYY_NO_INPUT
> -Wl,-export-dynamic -shared -fpic -o m_xt.so m_xt.c $(pkg-config xtables
> --cflags --libs)
> ----

I saw the same during make, _but_, on running `ldd tc/m_xt.so`, I got a
libxtables.so entry, so I thought I was fine.



"$() "is something for the shell to expand, not make. See this testcase.

$ make
echo $(pkg-config xtables --cflags --libs)
-I/usr/include/iptables-1.4.16.3 -lxtables
$ cat Makefile 
a:
        echo $$(pkg-config xtables --cflags --libs)
