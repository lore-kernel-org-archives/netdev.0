From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net v3] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 4 Feb 2015 19:54:56 +0900
Message-ID: <CAAedzxptQEX+c+khEmO7QvU+58+3W+iuOJ3O9zBfuWbWjFkakw@mail.gmail.com>
References: <1422859156-30691-1-git-send-email-ek@google.com>
 <CAKD1Yr0k44kwwtfWN-t9C1f7WKT0o=yimPwbfLtBnnvUvXrm=w@mail.gmail.com>
 <CAAedzxoF2gJit1e05UJSOWX2RJwbA1PSbdABK3zgta-XtajJyw@mail.gmail.com> <CAKD1Yr18AvHChpSJau5O2GypDRZ39sGaDfnjV4f73C77gYCXVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:53695 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964864AbbBDKzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 05:55:17 -0500
Received: by mail-qa0-f52.google.com with SMTP id x12so506470qac.11
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 02:55:17 -0800 (PST)
In-Reply-To: <CAKD1Yr18AvHChpSJau5O2GypDRZ39sGaDfnjV4f73C77gYCXVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 7:47 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> On Wed, Feb 4, 2015 at 7:38 PM, Erik Kline <ek@google.com> wrote:
>> One more thing I just noticed, though: if the interface and the
>> address matches the supplied arguments but we don't like the flags we
>> keep on processing all other addresses on that interface I think.  Is
>> that right?  (Easy to fix in a follow on patch.)
>
> What else would the code do? It loops over all the addresses on the
> system in hash table order, not interface-by-interface.

<off_topic>
Well, I was wondering about:

        hlist_for_each_entry_rcu(...) {
                if (!net_eq(dev_net(ifp->idev->dev), net))
                        continue;
                if (!ipv6_addr_equal(&ifp->addr, addr))
                        continue;

                if (flags_testing && etc) { unlock; return 1; }
                else break;
        }

But the correctness of this depends on where else an identical IPv6
address might be assigned.  Hard for me to say without more dedicated
time to study it.
</off_topic>
