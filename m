From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 01:59:33 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:35601 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781Ab2LPA7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2012 19:59:37 -0500
In-Reply-To: <20121216002755.GA11773@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sunday 2012-12-16 01:27, Pablo Neira Ayuso wrote:
>On Sat, Dec 15, 2012 at 04:19:29PM -0500, Jamal Hadi Salim wrote:
>> Example, the following should work for
>> tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0
>> action ipt -j CONNMARK \
>> action mirred egress redirect dev ifb0
>> 
>commit 7299fa4b615d7f7ee12cde444266f6b31f667f9f
>    libxt_CONNMARK: use guided option parser
>
>BTW, I think it would be good if we find the way to check for
>libxtables current version (see iptables/configure.ac), so you can
>know that we broke binary compatibility again.

For the C level, there is XTABLES_VERSION_CODE.

#if XTABLES_VERSION_CODE >= 6
	if (m != NULL && m->x6_parse != NULL)
		m->x6_parse(...)
#else
	else if (m != NULL && m->parse != NULL)
		m->parse(...)
	...

We can also export this through pkgconfig, similar to how
downstream users are to discover the plugin dir
(`pkg-config xtables --variable libdir`).
