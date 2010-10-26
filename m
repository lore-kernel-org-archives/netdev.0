From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 15:53:50 -0700
Message-ID: <AANLkTik2Q=fF9j6eiBQx33e2JU7EG3Sc5hnXyDH24+mt@mail.gmail.com>
References: <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
 <20101026.104710.232747902.davem@davemloft.net> <AANLkTikFnwM9Ks6h1Jb0+pNW6rkmcKnbVNzKdXUqPnHU@mail.gmail.com>
 <20101026.112321.258116003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49761 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab0JZWyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 18:54:13 -0400
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o9QMsCZq025309
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 15:54:12 -0700
Received: from gwaa11 (gwaa11.prod.google.com [10.200.27.11])
	by wpaz5.hot.corp.google.com with ESMTP id o9QMraIe016081
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 15:54:11 -0700
Received: by gwaa11 with SMTP id a11so13095gwa.34
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 15:54:11 -0700 (PDT)
In-Reply-To: <20101026.112321.258116003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 11:23 AM, David Miller <davem@davemloft.net> wrote:
>> This works pretty well. Why not do the same for IPv6? The only
>> difference in IPv6 is that the kernel is the one doing
>> autoconfiguration, so it's the kernel that should be doing the asking.
>
> That should be fine, but if I have static IPv6 addresses assigned to
> an interface I really don't want them changing on a simple link flap.

As the patch stands, they don't. Only autoconfigured addresses will be
cleared, because addrconf_ifdown() does not remove any addresses that
are permanent (unless they are link-local, in which case they are
recreated as soon as link comes back).
