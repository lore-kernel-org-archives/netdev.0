From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC v2 3/7] net: netfilter conntrack - add per-net
	functionality for SCTP protocol
Date: Mon, 16 Mar 2009 21:45:36 +0300
Message-ID: <20090316184536.GH7551@localhost>
References: <20090311205706.141086138@gmail.com> <20090311210817.384140456@gmail.com> <49BE71AF.8050200@trash.net> <20090316154620.GA7551@localhost> <49BE74CC.8060701@trash.net> <20090316182136.GF7551@localhost> <49BE9A6E.4030904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, daniel.lezcano@free.fr,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49BE9A6E.4030904@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Patrick McHardy - Mon, Mar 16, 2009 at 07:29:02PM +0100]
> Cyrill Gorcunov wrote:
>> After playing a bit with ctrl tables (thought about additional
>> mapping set or say new sysctl helper structure, or even using
>> extra1 member from struct ctl_table as temporary index) -- you were 
>> right in your first propose on this patch. Iterative
>> fasion is only more or less convenient here indeed :)
>>
>> Patrick, take a look please on the snippet below (that is how
>> it looks now).
>> ...
>
>> +	for (i = SCTP_CONNTRACK_CLOSED; i < SCTP_CONNTRACK_MAX; i++)
>> +		sn->sysctl_table[i - 1].data = &sn->sctp_timeouts[i];
>
> That definitely looks nicer. Does this work (-1) for the other
> protocols as well?

Yes, it's allowable for TCP_CONNTRACK_ to use the same way
referring just fine, though we use only a subset of the enum
for sysctl table.

>
>> If such an approach is fine -- I will fix the TCP proto
>> as well. Btw, this two patches (SCTP and TCP) are only
>> involved in such a modification, are there some problems
>> with patches for UDP, UDPlite and ICMP protos?
>
> Its better than the macro and I don't really see a better way, so
> this is fine with me. About the other patches - I just stopped at
> SCTP since it was the first one I truely didn't like :)
>

Ah :) Then I update only these two patches (SCTP and TCP protos)
since other are not related in this. Or I could resend the whole
series excluding the patches you've already picked up. Just say
what would be more convenient for you.

	- Cyrill -
