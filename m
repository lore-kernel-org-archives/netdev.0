From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: MASQUERADE/SNAT and multiple interfaces with the same IP
Date: Fri, 16 Aug 2013 13:14:46 +0200
Message-ID: <CAKfDRXgNtPgQjtrSL=oVkws6GB_sTv+h+-_GLVvVvpWoEHBRnw@mail.gmail.com>
References: <CAKfDRXjXkY--PjXAa1m=As+Vf_1__WBokkTAE5BHg+gxsM9Yxw@mail.gmail.com>
	<20130816110443.GB5154@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:51367 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356Ab3HPLOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 07:14:47 -0400
In-Reply-To: <20130816110443.GB5154@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you very much for your reply.

On Fri, Aug 16, 2013 at 1:04 PM, Florian Westphal <fw@strlen.de> wrote:>
> The MASQUERADE target zaps conntracks that it "owned" when the
> associated link goes down, see masq_device_event() in ipt_MASQUERADE.c

I added a pr_info() here to see when this function was called. It is
triggered when the link goes down, as expected, but not when I just
change the mark and move the flows to another interface. I still see
the DESTROY/NEW-behavior though.

> Also, the nat core zaps conntracks when they are sent out on an
> interface other than the original interface.
>
> See nf_nat_oif_changed() in iptable_nat.c

Thanks for letting me know, I will start looking into this function.
Does this mean that even when using SNAT, the old mapping is deleted
and a new created? And does this event not notify conntrack? I have so
far used conntrack -E to monitor changes to nat, but that is perhaps
incorrect?

-Kristian
