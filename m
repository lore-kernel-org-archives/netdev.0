From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 19:59:22 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212161850530.27614@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr>
 <50CE0921.7060306@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:37152 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752980Ab2LPS70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 13:59:26 -0500
In-Reply-To: <50CE0921.7060306@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sunday 2012-12-16 18:47, Jamal Hadi Salim wrote:
>
>> old parse has not entered any deprecation stage yet, since there are still
>> plugins out there (both the 5 and external ones) that make use of it.
>> Right now, both parse and x6_parse are valid.
>
> True - but we are getting broken because we are using a call that only 5 or so
> users provide. It would have saved us time if we got the
> a good log message instead of checking for if !m->parse()

A certainly safe bet would be to write, at the top of tc/m_xt.c,

#if XTABLES_VERSION_CODE > 9
#	error Someone call the guy who changed iptables and \
		make him fix it^W^W^W^W say you need help.
#endif

Then I would automatically notify myself of "oh I need fix that too" when I
feed any new releases of {iptables, iproute} through the Open Build Service.

>> Yes, all those with an x6_ prefix are new.
>> Mh, I already dream of plans reducing m_xt to something that
>> does not require libxtables.so anymore.
>
> That would be nice - but someone is going to have to link to libxtables, no?

I hope the complete opposite.

The following is a rough, it-compiles, untested never-run, draft of a
module. The vision here is that userspace only ever sends a chain
name to the kernel. The git tree/branch for it is

	git://git.inai.de/linux xt2-pktsched

commit 42c559c148cbbc22bf2cc29f2ad08bc330891838

    net_sched: act: new action to call into Xtables2 chains

 include/net/netfilter/xt_core.h    |    8 ++
 include/uapi/linux/tc_act/tc_ipt.h |    2 +
 net/netfilter/xt_core.c            |    3 +-
 net/sched/Kconfig                  |    9 ++
 net/sched/Makefile                 |    1 +
 net/sched/act_xtables.c            |  238 ++++++++++++++++++++++++++++++++++++
 6 files changed, 260 insertions(+), 1 deletion(-)
