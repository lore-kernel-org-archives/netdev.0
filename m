From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Mon, 24 Dec 2012 09:05:42 -0500
Message-ID: <50D86136.6070006@mojatatu.com>
References: <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com> <50D46060.2070308@gmail.com> <50D46928.9070809@mojatatu.com> <50D46EC1.2040608@gmail.com> <50D5B366.30005@mojatatu.com> <50D5BC96.9010602@gmail.com> <50D5BF00.7050304@mojatatu.com> <50D83DDB.102@mojatatu.com> <50D8413C.8050508@openwrt.org> <20121224131233.GA29307@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
	Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57427 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620Ab2LXOFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 09:05:55 -0500
Received: by mail-ie0-f180.google.com with SMTP id c10so9109055ieb.11
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2012 06:05:54 -0800 (PST)
In-Reply-To: <20121224131233.GA29307@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On 12-12-24 08:12 AM, Pablo Neira Ayuso wrote:

>
> conntrack needs to see defragmented packets, you have to call
> nf_defrag_ipv4 / _ipv6 respectively before that.
>

This should not be too hard to do - although my thinking says this
should be a separate action.

> This also changes the semantics of the raw table in iptables since it
> will now see packet with conntrack already attached. So this would
> also break -j CT --notrack.
>

Is there a flag we can check which says a flow is not to be tracked?
Doesnt nf_conntrack_in() fail if --no track is set?

> This needs more thinking. I can appreciate the value of calling
> conntrack from different points of the packet traversal, but there are
> a couple of thing we have to resolve before allowing that.

There is user need for this Pablo - as you can see from what Felix
deployed it seems to be used a lot more wider audience dependency.
What do we need to do to get this to work properly?

cheers,
jamal
