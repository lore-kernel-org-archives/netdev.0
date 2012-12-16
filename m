From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] build: unbreak linkage of m_xt.so
Date: Sun, 16 Dec 2012 12:03:55 -0500
Message-ID: <50CDFEFB.2070208@mojatatu.com>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr> <1355617968-26138-1-git-send-email-jengelh@inai.de> <50CDA2DA.3060805@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, vapier@gentoo.org,
	netdev@vger.kernel.org, urykhy@gmail.com, shemonc@gmail.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50CDA2DA.3060805@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-16 05:30 AM, Jamal Hadi Salim wrote:

> I can confirm it builds fine for me now if i take out the hack I had and
> use this patch.


Sorry, I take what i said back and went back to explicitly adding -l 
xtables. The problem is still the intepretation of tc/Makefile. Here's 
the compile output.
----
gcc -Wall -Wstrict-prototypes -O2 -I../include -DRESOLVE_HOSTNAMES 
-DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE 
-DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DIR=\"/lib/xtables\" 
-DYY_NO_INPUT -Wl,-export-dynamic -shared -fpic -o m_xt.so m_xt.c 
$(pkg-config xtables --cflags --libs)
----

Note the missing expansion.

cheers,
jamal
