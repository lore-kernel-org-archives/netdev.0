From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 18:21:08 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:36969 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513Ab2LPRVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 12:21:11 -0500
In-Reply-To: <50CDA5BE.2080800@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sunday 2012-12-16 11:43, Jamal Hadi Salim wrote:

> On 12-12-15 07:59 PM, Jan Engelhardt wrote:
>>
>
>> For the C level, there is XTABLES_VERSION_CODE.
>>
>> #if XTABLES_VERSION_CODE >= 6
>> 	if (m != NULL && m->x6_parse != NULL)
>> 		m->x6_parse(...)
>> #else
>> 	else if (m != NULL && m->parse != NULL)
>> 		m->parse(...)
>> 	...
>>
>
> I think you are suggesting this to be done in tc. That would make it easier to
> fix.
> IMO, it is easier to keep backward compat if you left the old
> APIs around for a period of time

As you can see, the old ->parse() that goes back to libxtables.so.0
still remains. It's just that... only 5 out of 99 plugins still come
with an old parse function.

	[m_xt] -> [libxtables] <- (plugins: libxt_*.so)

> and maybe log a warning that they
> will be deprecated over a period of time (sort of like kernel approach to
> changing APIs).

old parse has not entered any deprecation stage yet, since there are still
plugins out there (both the 5 and external ones) that make use of it.
Right now, both parse and x6_parse are valid.

> BTW: another interface that seems to have changed that we
> need is m->final_check().

Yes, all those with an x6_ prefix are new.
Mh, I already dream of plans reducing m_xt to something that
does not require libxtables.so anymore.
