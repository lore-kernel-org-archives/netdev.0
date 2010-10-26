From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:13:45 -0700
Message-ID: <AANLkTin-u_bZj6_wpoV6fNaLg81JbFN0EvhNrA6wX6SG@mail.gmail.com>
References: <20101025213841.635b9a15@nehalam> <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
 <4CC708CE.4040404@hp.com> <20101026.101038.260090183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:7829 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932359Ab0JZROJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:14:09 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o9QHE7g1025119
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:14:07 -0700
Received: from gyg8 (gyg8.prod.google.com [10.243.50.136])
	by kpbe14.cbf.corp.google.com with ESMTP id o9QHDYZ1002978
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:14:06 -0700
Received: by gyg8 with SMTP id 8so5073588gyg.25
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:14:05 -0700 (PDT)
In-Reply-To: <20101026.101038.260090183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:10 AM, David Miller <davem@davemloft.net> wrote:
> It would be fundamentally flawed, in my opinion, if the normal
> mechanisms of ipv6 cannot handle this situation adequately.

I think they can. When you associate with a new link, you naturally
set up link-local addresses, perform DAD for them, and send router
solicitations. You just need to make sure you don't have old addresses
from a previous link you were on before.

Removing autoconfigured addresses is what the kernel currently does
when the link goes down. The patch just makes sure it happens when
carrier is lost as well, since losing link might mean that when
carrier comes back, the host might be on a different link than it was
before.
