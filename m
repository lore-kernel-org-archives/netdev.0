From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 11:17:27 -0700
Message-ID: <AANLkTikFnwM9Ks6h1Jb0+pNW6rkmcKnbVNzKdXUqPnHU@mail.gmail.com>
References: <AANLkTin-u_bZj6_wpoV6fNaLg81JbFN0EvhNrA6wX6SG@mail.gmail.com>
 <20101026.102145.246528067.davem@davemloft.net> <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
 <20101026.104710.232747902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:46409 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933477Ab0JZSRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:17:53 -0400
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o9QIHp9Q028622
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:17:51 -0700
Received: from ywc21 (ywc21.prod.google.com [10.192.3.21])
	by kpbe11.cbf.corp.google.com with ESMTP id o9QIHnlh027299
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:17:49 -0700
Received: by ywc21 with SMTP id 21so2644356ywc.41
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:17:49 -0700 (PDT)
In-Reply-To: <20101026.104710.232747902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:47 AM, David Miller <davem@davemloft.net> wrote:
> Why would you do this when there are link layer indications that
> we are attached to a different network?

Thinking about this some more, I don't think it's necessarily better.

The only thing that really knows the state of the network is the
network itself. IPv6 provides a mechanism that hosts can use to find
out what they should be doing: send an RA and process the resulting
RS. I think this is much cleaner than keeping local state, performing
layering violations (looking at MAC addresses) and getting information
from other systems in order to second-guess information that the host
can get simply by sending another RS.

If you think about it, this is what we do today in IPv4: when link is
lost, networkmanager *deletes IP addresses and routes* from the
interfaces, and then starts DHCP again when link comes back. That is,
asks the network for configuration information.

This works pretty well. Why not do the same for IPv6? The only
difference in IPv6 is that the kernel is the one doing
autoconfiguration, so it's the kernel that should be doing the asking.
