From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Fri, 28 May 2010 10:05:56 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005281001550.11570@obet.zrqbmnf.qr>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>  <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr> <1275024304.3754.45.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275024304.3754.45.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-05-28 07:25, Luciano Coelho wrote:
>
>Do you have any other suggestion on how I can associate the rules to
>specific interfaces?

-A INPUT -i foo -j do
-A do -j idletimer

A little funny, but actually this would allow me to keep a timer
for a group of interfaces rather than just per-if.

>> >+static int xt_idletimer_checkentry(const struct xt_tgchk_param *par)
>> >+{
>> >+	const struct xt_idletimer_info *info = par->targinfo;
>> >+	const struct ipt_entry *entryinfo = par->entryinfo;
>> >+	const struct ipt_ip *ip = &entryinfo->ip;
>> 
>> I'm not sure spying on ipt_ip is a long-term viable solution.
>
>Do you have any other suggestions on how I could get an interface
>associated with the rule? I thought about having the userspace pass the
>interface as an option to the rule (like I already do for the timeout
>value), but that looked ugly to me, since the interface can already be
>defined as part of the ruleset.

I have patches ready since a while that decouple ipt_ip
from a rule, so there is no guarantee that such will exist.
