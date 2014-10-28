From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Tue, 28 Oct 2014 17:59:06 +0900
Message-ID: <CAAedzxoKWVpu67vycM_b0O5bA7mpWP=PGvj_ENbZZEVFpoMGqw@mail.gmail.com>
References: <1414482141-27912-1-git-send-email-ek@google.com> <CAKD1Yr13oLyBsbuh92F91Fjno3Xv4vBQ1B__8Csoi0XUjJv9nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:35344 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbaJ1I71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 04:59:27 -0400
Received: by mail-qg0-f54.google.com with SMTP id q108so122979qgd.13
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 01:59:27 -0700 (PDT)
In-Reply-To: <CAKD1Yr13oLyBsbuh92F91Fjno3Xv4vBQ1B__8Csoi0XUjJv9nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>          *      Configure the address for reception. Now it is valid.
>>          */
>>
>> -       ipv6_ifa_notify(RTM_NEWADDR, ifp);
>> +       /* If optimistic DAD is in use, the notification was already sent
>> +        * in addrconf_dad_begin().
>> +        */
>> +       if (!ipv6_use_optimistic_addr(ifp->idev))
>> +               ipv6_ifa_notify(RTM_NEWADDR, ifp);
>
> Won't this result in not sending RTM_NEWADDR messages if
> use_optimistic is enabled on the interface, but the IP address that
> has just completed DAD is not an optimistic address (e.g., if it's a
> manually-configured address)?

Gah, yes.  I originally unconditionally sent the RTM_NEWADDR, but
there was some concern about sending duplicates so this was a weak
attempt to reduce spurious messages.

I still think sending the RTM_NEWADDR unconditionally is the right
thing, since we send them all the time when something about the
address changes (including timer-refresh on receipt of RAs).

I'll revert that bit and send an updated patch ASAP.

Thanks.
